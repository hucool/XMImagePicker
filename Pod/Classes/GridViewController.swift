//
//  AssetGridViewController.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/9.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Photos
import Foundation

class GridViewController: UIViewController {
    
    var albumInfo: Album!
    weak var pickerDelegate: PickerPhotoDelegate?
    // 所有图片
    fileprivate var assets = [PHAsset]()
    // 选中图片
    fileprivate var selectAssets = [PHAsset]()
    
    fileprivate lazy var imageRequestOptions: PHImageRequestOptions = {
        self.imageRequestOptions = PHImageRequestOptions()
        self.imageRequestOptions.resizeMode = .exact
        self.imageRequestOptions.isSynchronous = false
        self.imageRequestOptions.deliveryMode = .highQualityFormat
        return self.imageRequestOptions
    }()
    
    fileprivate lazy var imageManager: PHCachingImageManager = {
        self.imageManager = PHCachingImageManager()
        self.imageManager.allowsCachingHighQualityImages = false
        return self.imageManager
    }()
    
    fileprivate lazy var thumbnailSize: CGSize = {
        let layout = self.iAssetCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var itemSize = layout.itemSize
        let screenScale: CGFloat = UIScreen.main.scale
        self.thumbnailSize = CGSize(width: itemSize.width * screenScale, height: itemSize.height * screenScale)
        return self.thumbnailSize
    }()
    
    // MARK:- UIView
    
    fileprivate lazy var iBackButton: UIBarButtonItem = {
        self.iBackButton = UIBarButtonItem()
        self.iBackButton.title = ""
        return self.iBackButton
    }()
    
    fileprivate lazy var iPreviewButton: UIBarButtonItem = {
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        let button = UIButton(frame: rect)
        button.setTitle("预览", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(previewButtonAction), for: UIControlEvents.touchUpInside)
        self.iPreviewButton = UIBarButtonItem(customView: button)
        return self.iPreviewButton
    }()
    
    fileprivate lazy var iDoneButton: UIBarButtonItem = {
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        let button = UIButton(frame: rect)
        button.setTitle("完成", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(doneButtonAction), for: UIControlEvents.touchUpInside)
        self.iDoneButton = UIBarButtonItem(customView: button)
        return self.iDoneButton
    }()
    
    fileprivate lazy var iNumButton: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button.setBackgroundImage(UIImage(name: "photo_number_icon"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        self.iNumButton = UIBarButtonItem(customView: button)
        return self.iNumButton
    }()
    
    fileprivate lazy var iAssetCollectionView: UICollectionView = {
        let size: CGFloat = 4
        let margin: CGFloat = 5
        let width = (self.view.frame.size.width - (size + 1) * margin) / size
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: width, height: width)
        layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
        self.iAssetCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.iAssetCollectionView.delegate = self
        self.iAssetCollectionView.dataSource = self
        self.iAssetCollectionView.register(AssetCell.self)
        self.iAssetCollectionView.backgroundColor = .white
        return self.iAssetCollectionView
    }()
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = albumInfo.title
        view.backgroundColor = .white
        navigationItem.backBarButtonItem = iBackButton
        
        // setup toolbar
        navigationController?.isToolbarHidden = false
        let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                             target: nil,
                                             action: nil)
        let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                target: nil,
                                                action: nil)
        fixedSpaceItem.width = -10
        toolbarItems = [iPreviewButton, flexibleSpaceItem, iNumButton, fixedSpaceItem, iDoneButton]
        
        view.addSubview(iAssetCollectionView)
        
        loadAlbumPhotos()
        reloadNumButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.barStyle = .default
    }
    
    fileprivate func loadAlbumPhotos() {
        PhotoMannager.loadAlbumPhotos(collection: albumInfo.collection) { (assets) in
            self.assets = assets
            self.iAssetCollectionView.reloadData()
            guard assets.count > 0 else {
                return
            }
            
            let indexPath = IndexPath(row: assets.count - 1, section: 0)
            self.iAssetCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: false)
        }
    }
    
    fileprivate func reloadNumButton() {
        let numButton = iNumButton.customView as! UIButton
        numButton.isHidden = selectAssets.count == 0
        numButton.setTitle("\(selectAssets.count)", for: .normal)
    }
    
    func previewButtonAction() {
        guard selectAssets.count > 0 else {
            return
        }
        
        let vc = PreviewViewController()
        vc.assetSelectDelegate = self
        vc.assets = selectAssets
        vc.selectAssets = selectAssets
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func doneButtonAction() {
        var dic = [String : Any]()
        dic[XMImagePickerController.SelectAssetsKey] = selectAssets
        dic[XMImagePickerController.IsOriginalKey] = false
        NotificationCenter.default.post(name: .SelectImageDone, object: dic)
    }
    
}

// MARK:- UICollectionView

extension GridViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = assets[indexPath.row]
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as AssetCell
        cell.asset = asset
        cell.assetSelectDelegate = self
        cell.isSelectImage = selectAssets.contains(asset)
        cell.TypeisImage = asset.mediaType == .image
        
        PHCachingImageManager.default().requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: imageRequestOptions) { (image, info) in
            if cell.asset.localIdentifier == asset.localIdentifier {
                cell.iThumbImageView.image = image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PreviewViewController()
        vc.assets = assets
        vc.assetSelectDelegate = self
        vc.selectAssets = selectAssets
        vc.currentIndex = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK:- AssetSelectDelegate

protocol AssetSelectDelegate: class {
    
    func didSelectAsset(_ asset: PHAsset, isSelected select: Bool)
    
}

extension GridViewController: AssetSelectDelegate {
    
    func didSelectAsset(_ asset: PHAsset, isSelected select: Bool) {
        func relaodItems() {
            // 刷新列表
            let idx = assets.index(where: { (a) -> Bool in
                return assetEquals(a)
            })!
            iAssetCollectionView.reloadItems(at: [IndexPath(item: idx, section: 0)])
        }
        
        let vc = navigationController as! XMImagePickerController
        if select && selectAssets.count == vc.config.imageLimit {
            showTipAlert(vc.config.imageLimit)
            relaodItems()
            return
        }
        
        func assetEquals(_ a: PHAsset) -> Bool {
            return a.localIdentifier == asset.localIdentifier
        }
        
        if select && !selectAssets.contains(asset) {
            // 添加选中图片
            selectAssets.append(asset)
        } else {
            // 删除选中图片
            let idx = selectAssets.index(where: { (a) -> Bool in
                return assetEquals(a)
            })!
            selectAssets.remove(at: idx)
        }
        
        relaodItems()
        reloadNumButton()
    }
    
}


