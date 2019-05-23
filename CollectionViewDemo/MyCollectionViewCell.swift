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

  var didUpdate: (Bool) -> Void = { _ in }

  override func awakeFromNib() {
    super.awakeFromNib()
    showMoreButton.addTarget(self, action: #selector(showMore), for: .touchUpInside)
  }

  @objc func showMore() {
    isExpanded = !isExpanded
    didUpdate(isExpanded)
  }

  func configureWidth(with constant: CGFloat) {
    cellWidth = constant
  }

  override func prepareForReuse() {
    label.text = nil
    super.prepareForReuse()
  }

  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    let autoAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
    let size = contentView.systemLayoutSizeFitting(CGSize(width: cellWidth, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
    autoAttributes.frame = CGRect(origin: autoAttributes.frame.origin, size: size)
    if isExpanded {
      autoAttributes.size.height += 100
    }
    return autoAttributes
  }
}
