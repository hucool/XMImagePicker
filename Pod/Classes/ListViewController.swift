//
//  ViewController.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/8.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Photos

class ListViewController: UIViewController {
    
    /// all albums
    fileprivate var albumInfos: [Album] = []
    
    // MARK:- UIView
    
    fileprivate lazy var iBackButton: UIBarButtonItem = {
        self.iBackButton = UIBarButtonItem()
        self.iBackButton.title = "返回"
        return self.iBackButton
    }()
    
    fileprivate lazy var iAlbumTableView: UITableView = {
        self.iAlbumTableView = UITableView()
        self.iAlbumTableView.delegate = self
        self.iAlbumTableView.dataSource = self
        self.iAlbumTableView.register(AlbumCell.self)
        self.iAlbumTableView.frame = self.view.bounds
        self.iAlbumTableView.tableFooterView = UIView()
        return self.iAlbumTableView
    }()
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 
        navigationItem.backBarButtonItem = iBackButton
        
        // setup view
        view.addSubview(iAlbumTableView)
        
        loadCameraRoll()
        loadAllAlbums()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
    }
        
    fileprivate func loadCameraRoll() {
        let info = PhotoMannager.loadCameraRoll()
        pushGridViewController(albumInfo: info, animated: false)
    }
    
    fileprivate func pushGridViewController(albumInfo: Album, animated: Bool) {
        DispatchQueue.main.async(execute: {
            let vc = GridViewController()
            vc.albumInfo = albumInfo
            self.navigationController?.pushViewController(vc, animated: animated)
            
            // set navigationView
            self.title = "照片"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(self.cancleAction))
        })
    }
    
    func cancleAction() {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func loadAllAlbums() {
        DispatchQueue.global().async {
            self.albumInfos = PhotoMannager.laodAlbumList()
            DispatchQueue.main.async(execute: {
                self.iAlbumTableView.reloadData()
            })
        }
    }

}


// MARK:- UITableView

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumInfos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let info = albumInfos[indexPath.row]
        pushGridViewController(albumInfo: info, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as AlbumCell
        cell.albumInfo = albumInfos[indexPath.row]
        return cell
    }
    
}

// MARK:- AssetSelectDelegate

protocol PickerPhotoDelegate: class {
    
    func didEndPickingPhotos(_ photos: [Photo], photoIdentifiers identifier: [String])
    
}




