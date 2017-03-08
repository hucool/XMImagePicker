//
//  XMImagePickerController.swift
//  XMImagePicker
//
//  Created by tiger on 2017/3/3.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Photos
import Foundation

open class XMImagePickerController: UINavigationController {
    
    public typealias CallHandler = (_ photos: [Photo]) -> Void
    static let IsOriginalKey = "isOriginal"
    static let SelectAssetsKey = "selectAssets"
    var resultHandler: CallHandler?
    public var config: XMImagePickerOptions = XMImagePickerOptions()
    
    private override init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
    }
    
    private override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // setup navigationBar
        navigationBar.tintColor = .white
        navigationBar.isTranslucent = true
        navigationBar.barStyle = .blackTranslucent
        
        addNotification()
        checkAuthorizationStatus()
    }
    
    deinit {
        removeNotification()
    }
    
    // MARK:- Photos
    
    // request photo authorization
    
    fileprivate func checkAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            pushListViewController()
        case .notDetermined:
            requestAuthorization()
        case .denied, .restricted:
            showAuxiliaryView()
        }
    }
    
    fileprivate func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                self.pushListViewController()
            default:
                self.showAuxiliaryView()
            }
        }
    }
    
    // MARK:- Notification
    
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectImageDone),
                                               name: .SelectImageDone,
                                               object: nil)
    }
    
    fileprivate func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: .SelectImageDone, object: nil)
    }
    
    @objc private func selectImageDone(not: Notification) {
        guard let dic = not.object as? [String : Any] else {
            return
        }
        
        guard let s = dic[XMImagePickerController.SelectAssetsKey] as? [PHAsset] else {
            return
        }
        
        let o = (dic[XMImagePickerController.IsOriginalKey] as? Bool) ?? false
        PhotoMannager.requestImages(isMarkUrl: config.isMarkImageURL, isCreateThumbImage: !o, assets: s) { (photos) in
            if let handle = self.resultHandler {
                handle(photos)
                self.resultHandler = nil
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func pushListViewController() {
        DispatchQueue.main.async(execute: {
            self.viewControllers = [ListViewController()]
        })
    }
    
    fileprivate func showAuxiliaryView() {
        DispatchQueue.main.async(execute: {
            self.viewControllers = [TipVIewController()]
        })
    }
    
    public func setFinishPickingHandle(handle: @escaping(_ photos: [Photo]) -> Void) {
        resultHandler = handle
    }
    
}
