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

class CollectionViewController: UIViewController {
  @IBOutlet var collectionView: UICollectionView!
  private var data = DataProvider.data.map(Model.init)

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyCollectionViewCell")
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.prefetchDataSource = self
    (collectionView.collectionViewLayout as? CollectionViewListLayout)?.delegate = self

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
  var cachedHeight: [IndexPath: CGFloat] = [:]
}

extension CollectionViewController: UICollectionViewDataSourcePrefetching {
  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    let maxIndexPath = indexPaths.max() ?? IndexPath(item: 0, section: 0)
    if maxIndexPath.item + 1 >= collectionView.numberOfItems(inSection: maxIndexPath.section) {
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
}

extension CollectionViewController: CollectionViewListLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return cachedHeight[indexPath] ?? 50
  }
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let height = cell.bounds.height
    cachedHeight[indexPath] = height
  }

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
