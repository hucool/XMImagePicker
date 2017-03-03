//
//  AlbumInfo.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/8.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Photos
import Foundation

class Album {
    
    var count: Int
    var title: String
    var thumb: UIImage?
    var collection: PHAssetCollection
    
    init(collection: PHAssetCollection) {
        func transformAblumTitle(_ title: String) -> String {
            switch title {
            case "Slo-mo":
                return "慢动作"
            case "Recently Added":
                return "最近添加"
            case "Favorites":
                return "最爱"
            case "Recently Deleted":
                return "最近删除"
            case "Videos":
                return "视频"
            case "All Photos":
                return "所有照片"
            case "Selfies":
                return "自拍"
            case "Screenshots":
                return "屏幕快照"
            case "Camera Roll":
                return "相机胶卷"
            case "Time-lapse":
                return "延时摄影"
            case "Panoramas":
                return "全景照片"
            case "Bursts":
                return "连拍"
            case "Hidden":
                return "隐藏照片"
            default:
                return title
            }
        }
        
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        count = assets.count
        self.collection = collection
        title = transformAblumTitle(collection.localizedTitle!)
        
        guard count > 0 else {
            return
        }
        
        let screenScale: CGFloat = UIScreen.main.scale
        let imageSize = CGSize(width: 100 * screenScale, height: 100 * screenScale)
        
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.isSynchronous = true
        
        PHCachingImageManager.default().requestImage(for: assets.lastObject!, targetSize: imageSize, contentMode: .aspectFill, options: options) { (image, info) in
            // 处理获得的图片
            self.thumb = image
        }
    }
    

    
}
