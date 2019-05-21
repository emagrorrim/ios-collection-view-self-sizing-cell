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

// To add break point, no need a custom layout
class MyFlowLayout: UICollectionViewFlowLayout {
  override func invalidateLayout() {
    super.invalidateLayout()
  }
}

class ViewController: UIViewController {
  @IBOutlet var collectionView: UICollectionView!
  private var data = DataProvider.data.map(Model.init)

  override func viewDidLoad() {
    super.viewDidLoad()
    let layout = collectionView.collectionViewLayout as! MyFlowLayout
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    collectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyCollectionViewCell")
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.bounces = false

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
        self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          self.isLoading = false
        }
      }
    }
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
    cell.didUpdate = { [weak self] in
      self?.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
      self?.data[indexPath.item].isExpanded = self?.data[indexPath.item].isExpanded == false
    }
    return cell
  }
}
