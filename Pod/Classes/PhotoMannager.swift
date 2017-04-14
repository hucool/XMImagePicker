//
//  PhotoMannager.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/8.
//  Copyright © 2017年 xinma. All rights reserved.
//

import Photos
import Foundation
import WXImageCompress

struct PhotoMannager {
    
    static func laodAlbumList() -> [Album] {
        var albumInfos = [Album]()
        
        func loadCollections(_ collections: PHFetchResult<PHAssetCollection>) {
            collections.enumerateObjects({ (collection, index, stop) in
                let subtype = collection.assetCollectionSubtype
                // filter album (favorites, hidden, Recently Deleted)
                // Recently Deleted subtype = 1000000201
                if (subtype != .smartAlbumFavorites &&
                    subtype != .smartAlbumAllHidden &&
                    subtype.rawValue < 300) {
                    let albumInfo = Album(collection: collection)
                    if albumInfo.count > 0 {
                        if subtype.rawValue == 209 {
                            albumInfos.insert(albumInfo, at: 0)
                        } else {
                            albumInfos.append(albumInfo)
                        }
                    }
                }
            })
        }
        
        // load system albums
        let system = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                             subtype: .albumRegular,
                                                             options: nil)
        loadCollections(system)
        //        // system album sort by count
        //        albumInfos.sort { (a, b) -> Bool in
        //            return a.count > b.count
        //        }
        
        // load user albums
        let user = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        loadCollections(user as! PHFetchResult<PHAssetCollection>)
        
        return albumInfos
    }
    
    static func loadCameraRoll() -> Album {
        var info: Album?
        let system = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                             subtype: .albumRegular,
                                                             options: nil)
        for idx in 0..<system.count {
            let collection = system.object(at: idx)
            // Camera Roll subtype = 209
            guard collection.assetCollectionSubtype.rawValue == 209 else {
                continue
            }
            info = Album(collection: collection)
        }
        return info!
    }
    
    static func loadAlbumPhotos(collection: PHAssetCollection, resultHandler: @escaping(_ assets: [PHAsset]) -> Void) {
        DispatchQueue.global().async {
            var assets = [PHAsset]()
            let list = PHAsset.fetchAssets(in: collection, options: nil)
            for idx in 0..<list.count {
                let asset = list.object(at: idx)
//                if asset.mediaType == .image {
                    assets.append(asset)
//                }
            }
            DispatchQueue.main.async(execute: {
                resultHandler(assets)
            })
        }
    }
    
    static func requestOriginalImage(asset: PHAsset, resultHandler: @escaping(_ data: Data) -> Void) {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.resizeMode = .exact
        imageRequestOptions.isSynchronous = false
        imageRequestOptions.deliveryMode = .highQualityFormat
        PHCachingImageManager.default().requestImageData(for: asset, options: imageRequestOptions, resultHandler: { (data, a, o, i) in
            DispatchQueue.main.async(execute: {
                if data != nil {
                    resultHandler(data!)
                }
            })
        })
    }
    
    static func originalImageSize(asset: PHAsset,
                                  resultHandler: @escaping(_ size: String, _ identifier: String) -> Void) {
        PhotoMannager.requestOriginalImage(asset: asset) { (data) in
            resultHandler(data.format, asset.localIdentifier)
        }
    }
    
    static func requestImages(isMarkUrl: Bool, isCreateThumbImage: Bool, assets: [PHAsset],
                              resultHandler: @escaping(_ photos: [Photo]) -> Void) {
        DispatchQueue.global().async {
            var photos = [Photo]()
            for asset in assets {
                PhotoMannager.requestOriginalImage(asset: asset, resultHandler: { (data) in
                    var photo = Photo()
                    photo.identifier = asset.localIdentifier
                    
                    var originalP = Photo.P()
                    
                    let name = "\(asset.localIdentifier.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: "-", with: "")).JPG"
                    let url = ImageFileManager.shared.imageUrl(imageName: name)
                    
                    originalP.url = isMarkUrl ? url : nil
                    if let image = ImageFileManager.shared.exists(imageName: name) {
                        originalP.image = image
                    } else {
                        let image = UIImage(data: data)!
                        originalP.image = image
                        if isMarkUrl {
                            ImageFileManager.shared.sava(data: data, imageName: name)
                        }
                    }
                    photo.original = originalP
                    
                    if isCreateThumbImage {
                        var thumbP = Photo.P()
                        let url = ImageFileManager.shared.imageUrl(imageName: name, isThumb: true)
                        thumbP.url = isMarkUrl ? url : nil
                        if let image = ImageFileManager.shared.exists(imageName: name, isThumb: true) {
                            thumbP.image = image
                            thumbP.url = url
                        } else {
                            // 压缩图片
                            thumbP.image = photo.original.image.wxCompress()
                            
                            if isMarkUrl {
                                ImageFileManager.shared.sava(image: thumbP.image, imageName: name, isThumb: true)
                            }
                        }
                        photo.thumb = thumbP
                    }
                    
                    photos.append(photo)
                    guard photos.count == assets.count else {
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        resultHandler(photos)
                    })
                })
            }
        }
    }
    
}


