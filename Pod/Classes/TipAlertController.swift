//
//  TipAlertController.swift
//  XMImagePicker
//
//  Created by tiger on 2017/3/3.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Foundation

extension UIViewController {
    
    func showTipAlert() {
        let alertController = UIAlertController(title: "提示", message: "最大选中数量9", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
