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
  private var cellWidth: CGFloat = 0

  func configureWidth(with constant: CGFloat) {
    cellWidth = constant
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    label.text = nil
  }

  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
    layoutAttributes.size = label.sizeThatFits(CGSize(width: cellWidth, height: attributes.size.height))//label.sizeThatFits(attributes.size)
    return layoutAttributes
  }
}
