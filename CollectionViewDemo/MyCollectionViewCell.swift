//
//  MyCollectionViewCell.swift
//  CollectionViewDemo
//
//  Created by Xin Guo  on 2019/5/20.
//  Copyright © 2019 XinGuo. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
  @IBOutlet var label: UILabel!
  @IBOutlet var showMoreButton: UIButton!

  private var cellWidth: CGFloat = 0
  var isExpanded: Bool = false

  var didUpdate: () -> Void = {}

  override func awakeFromNib() {
    super.awakeFromNib()
    showMoreButton.addTarget(self, action: #selector(showMore), for: .touchUpInside)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      label.topAnchor.constraint(equalTo: contentView.topAnchor),
    ])
  }

  @objc func showMore() {
    isExpanded = !isExpanded
    didUpdate()
  }

  func configureWidth(with constant: CGFloat) {
    cellWidth = constant
  }

  override func prepareForReuse() {
    label.text = nil
    super.prepareForReuse()
  }

  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    layoutAttributes.size = contentView.systemLayoutSizeFitting(CGSize(width: cellWidth, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
    if isExpanded {
      layoutAttributes.size.height += 100
    }
    return layoutAttributes
  }
}
