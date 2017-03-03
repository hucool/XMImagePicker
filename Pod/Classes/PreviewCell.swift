//
//  ImagePreviewCell.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/13.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Photos
import Foundation

class PreviewCell: UICollectionViewCell {

    var localIdentifier: String!
    weak var tapDelegate: CellTapDelegate!

    var image: UIImage? {
        didSet {
            self.iImageView.image = image
            self.recoverSubviews()
        }
    }
    
    func recoverSubviews() {
        iZoomScrollView.setZoomScale(1, animated: false)
        resizeSubviews()
    }
    
    func resizeSubviews() {
        guard let image = iImageView.image else {
            return
        }
        var imageWidth = image.size.width
        var imageHeight = image.size.height
        let scale = iZoomScrollView.frame.width / imageWidth
        imageWidth = imageWidth * scale
        imageHeight = imageHeight * scale
        let contentSizeHeight = max(imageHeight, iZoomScrollView.frame.height)
        iImageView.frame.size = CGSize(width: imageWidth, height: imageHeight)
        iZoomScrollView.contentSize = CGSize(width: imageWidth, height: contentSizeHeight)
        if imageHeight < iZoomScrollView.frame.height {
            iImageView.center = CGPoint(x: imageWidth / 2, y: iZoomScrollView.frame.height / 2)
        } else {
            iImageView.center = CGPoint(x: imageWidth / 2, y: imageHeight / 2)
        }
    }
    
    fileprivate lazy var iZoomScrollView: UIScrollView = {
        self.iZoomScrollView = UIScrollView()
        self.iZoomScrollView.delegate = self
        self.iZoomScrollView.minimumZoomScale = 1
        self.iZoomScrollView.maximumZoomScale = 3
        self.iZoomScrollView.isUserInteractionEnabled = true
        self.iZoomScrollView.showsVerticalScrollIndicator = false
        self.iZoomScrollView.showsHorizontalScrollIndicator = false
        self.iZoomScrollView.frame = CGRect(x: PreviewViewController.ItemViewMargin, y: 0,
                                            width: self.frame.width - PreviewViewController.ItemViewMargin * 2,
                                            height: self.frame.height)
        return self.iZoomScrollView
    }()
    
    fileprivate lazy var iImageView: UIImageView = {
        self.iImageView = UIImageView()
        self.iImageView.contentMode = .scaleAspectFill
        self.iImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        tap.numberOfTapsRequired = 1
        tap.delaysTouchesBegan = true
        let tap2 = UIShortTapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap2.numberOfTapsRequired = 2
        tap.require(toFail: tap2)
        self.iImageView.addGestureRecognizer(tap2)
        self.iZoomScrollView.addGestureRecognizer(tap)
        
        return self.iImageView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        iZoomScrollView.addSubview(iImageView)
        contentView.addSubview(iZoomScrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK:- UITapGestureRecognizer

extension PreviewCell {
    
    func singleTap(tap: UITapGestureRecognizer) {
        tapDelegate.singleTap()
    }
    
    func doubleTap(tap: UITapGestureRecognizer) {
        if iZoomScrollView.zoomScale > 1 {
            iZoomScrollView.setZoomScale(0, animated: true)
        } else {
            let pointInView = tap.location(in: iImageView)
            
            let newZoomScale = iZoomScrollView.maximumZoomScale
            
            let scrollViewSize = iZoomScrollView.bounds.size
            let w = scrollViewSize.width / newZoomScale
            let h = scrollViewSize.height / newZoomScale
            let x = pointInView.x - (w / 2)
            let y = pointInView.y - (h / 2)
            
            let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
            iZoomScrollView.zoom(to: rectToZoomTo, animated: true)
        }
    }
    
}

// MARK:- UIScrollView

extension PreviewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return iImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((iZoomScrollView.frame.width - iZoomScrollView.contentSize.width) / 2, 0)
        let offsetY = max((iZoomScrollView.frame.height - iZoomScrollView.contentSize.height) / 2, 0)
        iImageView.center = CGPoint(x: iZoomScrollView.contentSize.width / 2 + offsetX, y:  iZoomScrollView.contentSize.height / 2 + offsetY)
    }
    
}

@objc protocol CellTapDelegate: class {
    
    func singleTap()
    
}




