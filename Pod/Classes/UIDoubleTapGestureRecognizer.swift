//
//  UIDoubleTapGestureRecognizer.swift
//  XMImagePicker
//
//  Created by tiger on 2017/3/3.
//  Copyright © 2017年 xinma. All rights reserved.
//


import Foundation
import UIKit.UIGestureRecognizerSubclass

class UIShortTapGestureRecognizer: UITapGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            if self.state != .recognized {
                self.state = .failed
            }
        }
    }
    
}
