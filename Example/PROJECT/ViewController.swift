//
//  ViewController.swift
//  PROJECT
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright (c) TODAYS_YEAR PROJECT_OWNER. All rights reserved.
//

import UIKit
import XMImagePicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton()
        button.backgroundColor = .red
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.addTarget(self, action: #selector(pushController), for: .touchUpInside)
        view.addSubview(button)
    }
    
    func pushController() {
        let nv = XMImagePickerController()
        nv.config = XMImagePickerOptions(imageLimit: 2)
        nv.config.isMarkImageURL = true
        
        nv.setFinishPickingHandle { (photos) in
            let images = photos.flatMap{ $0.original.image }
            print(images)
        }
        present(nv, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

