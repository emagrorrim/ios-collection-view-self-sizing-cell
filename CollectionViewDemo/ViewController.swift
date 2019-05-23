//
//  Copyright © 2016 XinGuo. All rights reserved.
//

import UIKit

struct Model {
  let name: String
  var isExpanded: Bool = false

  init(name: String) {
    self.name = name
  }
}

extension UIViewController: UITableViewDelegate {
}

protocol ListLayoutDelegate: class {
  func collectionView(_ collectionView: UICollectionView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
}

class MyFlowLayout: UICollectionViewLayout {

  weak var delegate: ListLayoutDelegate? = nil

  var contentBounds = CGRect.zero
  var cachedAttributes = [UICollectionViewLayoutAttributes]()

  override func prepare() {
    super.prepare()

    guard let collectionView = collectionView, cachedAttributes.isEmpty else { return }

    contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)

    var lastFrame: CGRect = .zero

    for currentIndex in 0 ..< collectionView.numberOfItems(inSection: 0) {
      let indexPath = IndexPath(item: currentIndex, section: 0)
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      let estimatedRowHeight: CGFloat = delegate?.collectionView(collectionView, estimatedHeightForRowAt: indexPath) ?? 50
      let itemFrame = CGRect(x: 0, y: lastFrame.maxY + 1.0, width: collectionView.bounds.width, height: estimatedRowHeight)
      attributes.frame = itemFrame
      lastFrame = itemFrame

      cachedAttributes.append(attributes)
      contentBounds = contentBounds.union(lastFrame)
    }
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var attributesArray = [UICollectionViewLayoutAttributes]()

    guard let lastIndex = cachedAttributes.indices.last,
      let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }

    for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
      guard attributes.frame.maxY >= rect.minY else { break }
      attributesArray.append(attributes)
    }

    for attributes in cachedAttributes[firstMatchIndex...] {
      guard attributes.frame.minY <= rect.maxY else { break }
      attributesArray.append(attributes)
    }

    return attributesArray
  }

  private func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
    if end < start { return nil }

    let mid = (start + end) / 2
    let attr = cachedAttributes[mid]

    if attr.frame.intersects(rect) {
      return mid
    } else {
      if attr.frame.maxY < rect.minY {
        return binSearch(rect, start: (mid + 1), end: end)
      } else {
        return binSearch(rect, start: start, end: (mid - 1))
      }
    }
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cachedAttributes[indexPath.item]
  }

  override var collectionViewContentSize: CGSize {
    return contentBounds.size
  }

  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let collectionView = collectionView else { return false }
    return !newBounds.size.equalTo(collectionView.bounds.size)
  }

  override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
    super.invalidateLayout(with: context)
    if context.invalidateEverything {
      cachedAttributes = []
    }
  }

  override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
    let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
    guard let collectionView = collectionView else { return context }

    let contentHeightAdjustment: CGFloat = preferredAttributes.frame.size.height - originalAttributes.frame.size.height

    let attributes = cachedAttributes[originalAttributes.indexPath.item]
    attributes.frame.size.height += contentHeightAdjustment
    attributes.frame.size.width = collectionView.bounds.width

    context.invalidateItems(at: [attributes.indexPath])

    cachedAttributes[originalAttributes.indexPath.item] = attributes

    (originalAttributes.indexPath.item + 1 ..< collectionView.numberOfItems(inSection: 0)).forEach { index in
      let itemLayoutAttributes = self.cachedAttributes[index]
      itemLayoutAttributes.frame.origin.y += contentHeightAdjustment
      context.invalidateItems(at: [itemLayoutAttributes.indexPath])
    }

    context.contentSizeAdjustment = CGSize(width: 0, height: contentHeightAdjustment)
    contentBounds.size.height += contentHeightAdjustment

    return context
  }

  override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
    guard let collectionView = collectionView else { return false }
    return preferredAttributes.frame.size.height != originalAttributes.frame.size.height || originalAttributes.size.width != collectionView.bounds.width
  }
}

class ViewController: UIViewController {
  @IBOutlet var collectionView: UICollectionView!
  private var data = DataProvider.data.map(Model.init)

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyCollectionViewCell")
    collectionView.delegate = self
    collectionView.dataSource = self
    (collectionView.collectionViewLayout as? MyFlowLayout)?.delegate = self

    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    collectionView.refreshControl = refreshControl
  }

  @objc private func refresh() {
    data = DataProvider.data.map(Model.init)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      self?.collectionView.reloadData()
      self?.collectionView.refreshControl?.endRefreshing()
    }
  }

  var isLoading: Bool = false
  var isFirstTime: Bool = true

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if isFirstTime {
      isFirstTime = false
      return
    }
    if scrollView.contentOffset.y + scrollView.bounds.height >= scrollView.contentSize.height && !isLoading {
      isLoading = true
      self.data.append(contentsOf: DataProvider.data.map(Model.init))
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        self.collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          self.isLoading = false
        }
      }
    }
  }

  var cachedHeight: [IndexPath: CGFloat] = [:]

  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let height = cell.bounds.height
    cachedHeight[indexPath] = height
  }
}

extension ViewController: ListLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return cachedHeight[indexPath] ?? 50
  }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as? MyCollectionViewCell else {
      return UICollectionViewCell()
    }
    cell.configureWidth(with: collectionView.bounds.width)
    cell.label.text = "\(indexPath.item) \n" + data[indexPath.item].name
    cell.contentView.backgroundColor = .cyan
    cell.isExpanded = data[indexPath.item].isExpanded
    cell.didUpdate = { [weak self] newState in
      self?.data[indexPath.item].isExpanded = newState
      self?.collectionView.reloadData()
    }
    return cell
  }
}
