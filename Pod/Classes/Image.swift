//
//  Image.swift
//  Pods
//
//  Created by tiger on 2017/3/3.
//
//

import UIKit
import Foundation

extension UIImage {
    
    public convenience init(name: String) {
        let bundle = Bundle(for: XMImagePickerController.self)
        self.init(named: "image.bundle/\(name)", in: bundle, compatibleWith: nil)!
    }
    
}
