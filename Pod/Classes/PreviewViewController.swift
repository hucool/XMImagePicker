//
//  PreviewViewController.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/13.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Photos
import Foundation

class PreviewViewController: UIViewController {
    
    static let ItemViewMargin: CGFloat = 10
    
    var currentIndex = 0
    var lastLoadOriginalIndex = 0
    var assets: [PHAsset]!
    var selectAssets: [PHAsset]!
    weak var assetSelectDelegate: AssetSelectDelegate!
    
    fileprivate lazy var imageRequestOptions: PHImageRequestOptions = {
        self.imageRequestOptions = PHImageRequestOptions()
        self.imageRequestOptions.resizeMode = .exact
        self.imageRequestOptions.isSynchronous = false
        self.imageRequestOptions.deliveryMode = .highQualityFormat
        return self.imageRequestOptions
    }()
    
    fileprivate lazy var imageSize: CGSize = {
        let w = self.view.frame.size.width / 1.5
        let h = self.view.frame.size.height / 1.5
        return CGSize(width: w, height: h)
    }()
    
    fileprivate var hidStatusBar = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return hidStatusBar
    }
    
    fileprivate lazy var iSelectButton: UIButton = {
        self.iSelectButton = UIButton()
        self.iSelectButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        self.iSelectButton.setImage(UIImage(name: "photo_def_photoPickerVc"), for: .normal)
        self.iSelectButton.setImage(UIImage(name: "photo_sel_photoPickerVc"), for: .selected)
        self.iSelectButton.isSelected = self.selectAssets.contains(self.assets[self.currentIndex])
        self.iSelectButton.addTarget(self, action: #selector(selectImageAction), for: UIControlEvents.touchUpInside)
        return self.iSelectButton
    }()
    
    fileprivate lazy var iDoneButton: UIBarButtonItem = {
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        let button = UIButton(frame: rect)
        button.setTitle("完成", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(doneButtonAction), for: UIControlEvents.touchUpInside)
        self.iDoneButton = UIBarButtonItem(customView: button)
        return self.iDoneButton
    }()
    
    fileprivate lazy var iOriginalButton: UIButton = {
        let rect = CGRect(x: 0, y: 0, width: 70, height: 40)
        self.iOriginalButton = UIButton(frame: rect)
        self.iOriginalButton.setTitle("原图", for: .normal)
        self.iOriginalButton.contentHorizontalAlignment = .left
        self.iOriginalButton.setTitleColor(.white, for: .normal)
        self.iOriginalButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.iOriginalButton.setImage(UIImage(name: "photo_original_def"), for: .normal)
        self.iOriginalButton.setImage(UIImage(name: "photo_original_sel"), for: .selected)
        self.iOriginalButton.addTarget(self, action: #selector(selectOriginalAction), for: UIControlEvents.touchUpInside)
        self.iOriginalButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        return self.iOriginalButton
    }()
    
    fileprivate lazy var iNumButton: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button.setBackgroundImage(UIImage(name: "photo_number_icon"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        self.iNumButton = UIBarButtonItem(customView: button)
        return self.iNumButton
    }()
    
    fileprivate lazy var iPreviewCollectionView: UICollectionView = {
        // init UICollectionViewFlowLayout
        let itemViewHeight = self.view.frame.height
        let itemViewWidth = self.view.frame.width + PreviewViewController.ItemViewMargin * 2
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: itemViewWidth, height: itemViewHeight)
        // init UICollectionView
        let rect = CGRect(x: PreviewViewController.ItemViewMargin * -1, y: 0,
                          width: itemViewWidth, height: itemViewHeight)
        let contentSizeWidth = itemViewWidth * CGFloat(self.assets.count)
        self.iPreviewCollectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        self.iPreviewCollectionView.delegate = self
        self.iPreviewCollectionView.dataSource = self
        self.iPreviewCollectionView.scrollsToTop = false
        self.iPreviewCollectionView.isPagingEnabled = true
        self.iPreviewCollectionView.backgroundColor = .black
        self.iPreviewCollectionView.register(PreviewCell.self)
        self.iPreviewCollectionView.contentOffset = CGPoint(x: 0, y: 0)
        self.iPreviewCollectionView.showsHorizontalScrollIndicator = false
        self.iPreviewCollectionView.contentSize = CGSize(width: contentSizeWidth, height: itemViewHeight)
        self.iPreviewCollectionView.setContentOffset(CGPoint(x: itemViewWidth * CGFloat(self.currentIndex), y: 0), animated: false)
        return self.iPreviewCollectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        automaticallyAdjustsScrollViewInsets = false
        view.clipsToBounds = true
        view.addSubview(iPreviewCollectionView)
        // setup navigationView
        let originalItem = UIBarButtonItem(customView: iOriginalButton)
        let rightSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                             target: nil,
                                             action: nil)
        rightSpaceItem.width = -15
        navigationItem.rightBarButtonItems = [rightSpaceItem,
                                              UIBarButtonItem(customView: iSelectButton)]
        
        // setup toolbar
        navigationController?.isToolbarHidden = false
        let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                             target: nil,
                                             action: nil)
        let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                target: nil,
                                                action: nil)
        let leftSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        fixedSpaceItem.width = -10
        navigationController?.toolbar.barStyle = .blackTranslucent
        toolbarItems = [originalItem, leftSpaceItem, flexibleSpaceItem, iNumButton, fixedSpaceItem, iDoneButton]
        
        reloadNumButton()
        scrollViewDidEndDecelerating(iPreviewCollectionView)
    }
    
    func selectImageAction() {
        let selected = !iSelectButton.isSelected
        let vc = navigationController as! XMImagePickerController
        if selected && selectAssets.count == vc.config?.imageLimit {
            showTipAlert((vc.config?.imageLimit)!)
            return
        }
        
        iSelectButton.isSelected = selected
        let asset = assets[currentIndex]
        if iSelectButton.isSelected && !selectAssets.contains(asset) {
            selectAssets.append(asset)
        } else {
            let idx = selectAssets.index(where: { (a) -> Bool in
                return a.localIdentifier == asset.localIdentifier
            })
            selectAssets.remove(at: idx!)
        }
        
        assetSelectDelegate.didSelectAsset(asset, isSelected: selected)
        
        reloadNumButton()
    }
    
    func doneButtonAction() {
        var dic = [String : Any]()
        dic[XMImagePickerController.SelectAssetsKey] = selectAssets
        dic[XMImagePickerController.IsOriginalKey] = iOriginalButton.isSelected
        NotificationCenter.default.post(name: .SelectImageDone, object: dic)
    }
    
    func selectOriginalAction() {
        iOriginalButton.isSelected = !iOriginalButton.isSelected
        setImageSize()
        var f = iOriginalButton.frame
        f.size.width = iOriginalButton.isSelected ? 120 : 70
        iOriginalButton.frame = f
    }
    
    func setImageSize() {
        guard iOriginalButton.isSelected else {
            return
        }
        
        PhotoMannager.originalImageSize(asset: assets[currentIndex]) { (size, idf) in
            if idf == self.assets[self.currentIndex].localIdentifier {
                self.iOriginalButton.setTitle("原图(\(size))", for: .selected)
            }
        }
    }
    
    fileprivate func reloadNumButton() {
        let numButton = iNumButton.customView as! UIButton
        numButton.isHidden = selectAssets.count == 0
        numButton.setTitle("\(selectAssets.count)", for: .normal)
    }
    
}

// MARK:- UICollectionView

extension PreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = assets[indexPath.row]
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as PreviewCell
        cell.localIdentifier = asset.localIdentifier
        cell.tapDelegate = self
        
        PHCachingImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFit, options: self.imageRequestOptions) { (image, info) in
            if cell.localIdentifier == asset.localIdentifier {
                cell.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item != currentIndex else {
            return
        }
        recoverCell(cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        recoverCell(cell)
    }
    
    private func recoverCell(_ cell: UICollectionViewCell) {
        let c = cell as! PreviewCell
        c.recoverSubviews()
    }
    
}

// MARK:- UIScrollView

extension PreviewViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let idx = collectionViewCellIndex()
        if idx < assets.count && idx != currentIndex {
            currentIndex = idx
            iSelectButton.isSelected = selectAssets.contains(assets[currentIndex])
            setImageSize()
        }
    }
    
    private func collectionViewCellIndex() -> Int {
        let layout = iPreviewCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let itemSize = layout.itemSize
        var offSetWidth = iPreviewCollectionView.contentOffset.x
        offSetWidth = offSetWidth +  (itemSize.width / 2)
        let idx = Int(offSetWidth / itemSize.width)
        return idx
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let idx = collectionViewCellIndex()
        if idx < assets.count && idx != lastLoadOriginalIndex {
            let asset = assets[idx]
            let w = self.view.frame.size.width * UIScreen.main.scale
            let h = self.view.frame.size.height * UIScreen.main.scale
            let size = CGSize(width: w, height: h)
            PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: self.imageRequestOptions) { (image, info) in
                let cell = self.iPreviewCollectionView.cellForItem(at: IndexPath(item: idx, section: 0)) as! PreviewCell
                if cell.localIdentifier == asset.localIdentifier {
                    cell.image = image
                    self.lastLoadOriginalIndex = idx
                }
            }
        }
    }
    
}

extension PreviewViewController: CellTapDelegate {
    
    func singleTap() {
        hidStatusBar = !hidStatusBar
        navigationController?.isToolbarHidden = hidStatusBar
        navigationController?.isNavigationBarHidden = hidStatusBar
    }
    
}
