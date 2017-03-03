//
//  PhotoInfo.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/14.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Foundation

public struct Photo {
    
    /// asset标示
    var identifier: String!
    /// 缩略图
    var thumb: P?
    /// 原图
    var original: P!
    
    struct P {
        /// 图片本地存储路径
        var url: URL!
        /// 图片
        var image: UIImage!
    }
    
}

