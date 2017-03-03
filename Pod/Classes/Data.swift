//
//  Data.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/27.
//  Copyright © 2017年 xinma. All rights reserved.
//

import Foundation

extension Data {
    
    var format: String {
        let size = Double(self.count)
        var f = ""
        if size >= 1024 * 1024 * 0.1 {
            f = String.init(format: "%0.1fM", size / 1024 / 1024)
        } else if size >= 1024 {
            f = "\(Int(size / 1024))K"
        } else {
            f = "\(size)B"
        }
        return f
    }
    
}
