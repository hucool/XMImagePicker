//
//  AssetCell.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/9.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Photos
import Foundation

class AssetCell: UICollectionViewCell {
    
    var asset: PHAsset!
    weak var assetSelectDelegate: AssetSelectDelegate!

    var isSelectImage: Bool! {
        didSet {
            iSelectButton.isSelected = isSelectImage
        }
    }
    
     lazy var iThumbImageView: UIImageView = {
        self.iThumbImageView = UIImageView()
        self.iThumbImageView.frame = self.bounds
        return self.iThumbImageView
    }()
    
    private lazy var iSelectButton: UIButton = {
        self.iSelectButton = UIButton()
        self.iSelectButton.translatesAutoresizingMaskIntoConstraints = false
        self.iSelectButton.setBackgroundImage(UIImage(name: "photo_def_photoPickerVc"), for: .normal)
        self.iSelectButton.setBackgroundImage(UIImage(name: "photo_sel_photoPickerVc"), for: .selected)
        self.iSelectButton.addTarget(self, action: #selector(selectImageAction), for: UIControlEvents.touchUpInside)
        return self.iSelectButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iThumbImageView)
        contentView.addSubview(iSelectButton)
        constraintSetup()
    }
    
    func selectImageAction() {
        isSelectImage = !iSelectButton.isSelected
        assetSelectDelegate.didSelectAsset(asset, isSelected: isSelectImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constraintSetup() {
        contentView.addConstraint(NSLayoutConstraint.init(item: iSelectButton,
                                                          attribute: .top,
                                                          relatedBy: .equal,
                                                          toItem: contentView,
                                                          attribute: .top,
                                                          multiplier: 1,
                                                          constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: iSelectButton,
                                                          attribute: .right,
                                                          relatedBy: .equal,
                                                          toItem: contentView,
                                                          attribute: .right,
                                                          multiplier: 1,
                                                          constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: iSelectButton,
                                                          attribute: .width,
                                                          relatedBy: .equal,
                                                          toItem: nil,
                                                          attribute: .notAnAttribute,
                                                          multiplier: 1,
                                                          constant: 25))
        contentView.addConstraint(NSLayoutConstraint.init(item: iSelectButton,
                                                          attribute: .height,
                                                          relatedBy: .equal,
                                                          toItem: iSelectButton,
                                                          attribute: .width,
                                                          multiplier: 1,
                                                          constant: 0))
    }
    
}


