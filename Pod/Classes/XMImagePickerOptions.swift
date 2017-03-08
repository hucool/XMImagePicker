//
//  XMImagePickerOptions.swift
//  XMImagePicker
//
//  Created by tiger on 2017/3/3.
//  Copyright © 2017年 xinma. All rights reserved.
//

import Foundation

public struct XMImagePickerOptions {
    
    public var imageLimit: Int!
    public var isMarkImageURL: Bool!
    
    public init(imageLimit: Int = 9, isMarkImageURL: Bool = false) {
        self.imageLimit = imageLimit
        self.isMarkImageURL = isMarkImageURL
    }

}
