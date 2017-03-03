//
//  ThumbCell.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/8.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Foundation

class AlbumCell: UITableViewCell {
    
    var albumInfo: Album! {
        didSet {
            iTitleLabel.text = albumInfo.title
            iCountLabel.text = "(\(albumInfo.count))"
            if let thumb = albumInfo.thumb {
                iThumbImageView.image = thumb
            }
        }
    }
    
    // album title
    fileprivate lazy var iTitleLabel: UILabel = {
        self.iTitleLabel = UILabel()
        self.iTitleLabel.textColor = .black
        self.iTitleLabel.font = UIFont.systemFont(ofSize: 16)
        self.iTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return self.iTitleLabel
    }()
    
    // album photo conut
    fileprivate lazy var iCountLabel: UILabel = {
        self.iCountLabel = UILabel()
        self.iCountLabel.textColor = .gray
        self.iCountLabel.font = UIFont.systemFont(ofSize: 16)
        self.iCountLabel.translatesAutoresizingMaskIntoConstraints = false
        return self.iCountLabel
    }()
    
    // album thumb
    fileprivate lazy var iThumbImageView: UIImageView = {
        self.iThumbImageView = UIImageView()
        self.iThumbImageView.translatesAutoresizingMaskIntoConstraints = false
        return self.iThumbImageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(iTitleLabel)
        contentView.addSubview(iCountLabel)
        contentView.addSubview(iThumbImageView)
        
        constraintSetup()
    }
    
    
    private func constraintSetup() {
        // set album thumb imageView constraint
        contentView.addConstraint(NSLayoutConstraint.init(item: iThumbImageView,
                                                          attribute: .top,
                                                          relatedBy: .equal,
                                                          toItem: contentView,
                                                          attribute: .top,
                                                          multiplier: 1,
                                                          constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: iThumbImageView,
                                                          attribute: .bottom,
                                                          relatedBy: .equal,
                                                          toItem: contentView,
                                                          attribute: .bottom,
                                                          multiplier: 1,
                                                          constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: iThumbImageView,
                                                          attribute: .width,
                                                          relatedBy: .equal,
                                                          toItem: iThumbImageView,
                                                          attribute: .height,
                                                          multiplier: 1,
                                                          constant: 0))
        // set album name label constraint
        contentView.addConstraint(NSLayoutConstraint.init(item: iTitleLabel,
                                                          attribute: .centerY,
                                                          relatedBy: .equal,
                                                          toItem: contentView,
                                                          attribute: .centerY,
                                                          multiplier: 1,
                                                          constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: iTitleLabel,
                                                          attribute: .left,
                                                          relatedBy: .equal,
                                                          toItem: iThumbImageView,
                                                          attribute: .right,
                                                          multiplier: 1,
                                                          constant: 10))
        
        // set album number label constraint
        contentView.addConstraint(NSLayoutConstraint.init(item: iCountLabel,
                                                          attribute: .centerY,
                                                          relatedBy: .equal,
                                                          toItem: contentView,
                                                          attribute: .centerY,
                                                          multiplier: 1,
                                                          constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: iCountLabel,
                                                          attribute: .left,
                                                          relatedBy: .equal,
                                                          toItem: iTitleLabel,
                                                          attribute: .right,
                                                          multiplier: 1,
                                                          constant: 15))
        contentView.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
