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
    public var identifier: String!
    /// 缩略图
    public var thumb: P?
    /// 原图
    public var original: P!
    
    public struct P {
        /// 图片本地存储路径
        public var url: URL!
        /// 图片
        public var image: UIImage!
    }
    
}

