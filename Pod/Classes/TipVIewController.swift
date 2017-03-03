//
//  TipVIewController.swift
//  XMImagePicker
//
//  Created by tiger on 2017/3/3.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Foundation

class TipVIewController: UIViewController {
    
    fileprivate lazy var iTipLabel: UILabel = {
        self.iTipLabel = UILabel()
        self.iTipLabel.numberOfLines = 0
        self.iTipLabel.textAlignment = .center
        self.iTipLabel.lineBreakMode = .byCharWrapping
        self.iTipLabel.translatesAutoresizingMaskIntoConstraints = false
        self.iTipLabel.text = "请在iPhone的\"设置-隐私-照片\"选项中，\n允许访问你的手机相册。"
        return self.iTipLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "照片"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(dismissViewController))
        
        view.addSubview(iTipLabel)
        constraintSetup()
    }
    
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- constraint
    
    fileprivate func constraintSetup() {
        view.addConstraint(NSLayoutConstraint.init(item: iTipLabel,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .top,
                                                   multiplier: 1,
                                                   constant: 100))
        view.addConstraint(NSLayoutConstraint.init(item: iTipLabel,
                                                   attribute: .width,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .width,
                                                   multiplier: 1,
                                                   constant: 0))
        view.layoutIfNeeded()
    }
    
}
