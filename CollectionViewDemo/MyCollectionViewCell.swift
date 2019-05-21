//
//  MyCollectionViewCell.swift
//  CollectionViewDemo
//
//  Created by Xin Guo  on 2019/5/20.
//  Copyright © 2019 XinGuo. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
  var label = UILabel()
  private var cellWidth: CGFloat = 0

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(label)
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      label.topAnchor.constraint(equalTo: contentView.topAnchor),
      label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

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
