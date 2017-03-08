//
//  File.swift
//  XMImagePicker
//
//  Created by tiger on 2017/2/27.
//  Copyright © 2017年 xinma. All rights reserved.
//

import UIKit
import Foundation

class ImageFileManager {
    
    static let shared = ImageFileManager()
    
    private let manager = FileManager.default
    
    private lazy var cacheRootFolder: URL = {
        let documentUrl = URL(string: "file://" + NSTemporaryDirectory())
        return documentUrl!.appendingPathComponent("imagePickerCache",
                                                       isDirectory: true)
    }()
    private lazy var tuhmbFolder: URL = {
        return self.cacheRootFolder.appendingPathComponent("thumb",
                                                           isDirectory: true)
    }()
    private lazy var originalFolder: URL = {
        return self.cacheRootFolder.appendingPathComponent("original",
                                                           isDirectory: true)
    }()
    
    private init() {
        
    }
    
    private func creteFloder() {
        createDirectory(url: cacheRootFolder)
        createDirectory(url: tuhmbFolder)
        createDirectory(url: originalFolder)
    }
    
    private func createDirectory(url: URL) {
        guard !fileExists(atURL: url) else {
            return
        }
        
        try! manager.createDirectory(at: url,
                                     withIntermediateDirectories: true,
                                     attributes: nil)
    }
    
    private func fileExists(atURL url: URL) -> Bool {
        return manager.fileExists(atPath: url.filePath)
    }
    
    func imageUrl(imageName name: String, isThumb: Bool = false) -> URL {
        if isThumb {
            return tuhmbFolder.appendingPathComponent(name)
        } else {
            return originalFolder.appendingPathComponent(name)
        }
    }
    
    // 图片是否存在
    func exists(imageName name: String, isThumb: Bool = false) -> UIImage? {
        let url = imageUrl(imageName: name, isThumb: isThumb)
        guard fileExists(atURL: url) else {
            return nil
        }
        
        let data = try! Data.init(contentsOf: url)
        let image = UIImage(data: data)
        return image
    }
    
    // 保存图片
    func sava(image: UIImage, imageName name: String, isThumb: Bool = false) {
        let data = UIImagePNGRepresentation(image)!
        sava(data: data, imageName: name, isThumb: isThumb)
    }
    
    // 保存图片
    func sava(data: Data, imageName name: String, isThumb: Bool = false) {
        creteFloder()
        let url = imageUrl(imageName: name, isThumb: isThumb)
        if !fileExists(atURL: url) {
            try! data.write(to: url)
        }
    }
    
    // 清空所有缩略图
    func clean() {
        cleanDirectory(url: tuhmbFolder)
        cleanDirectory(url: originalFolder)
    }
    
    private func cleanDirectory(url: URL) {
        do {
            let fs = try manager.subpathsOfDirectory(atPath: url.filePath)
            for name in fs {
                let url = url.appendingPathComponent(name)
                try manager.removeItem(at: url)
            }
        } catch  {
            
        }
    }
    
    func size(filePath: String) {
        var fileSize : UInt64
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
            print(fileSize)
        } catch {
            print("Error: \(error)")
        }
    }
    
}

extension URL {
    
    var filePath: String {
        let f = "file://"
        let index = self.absoluteString.index(self.absoluteString.startIndex, offsetBy: f.characters.count)
        let path = self.absoluteString.substring(from: index)
        return path
    }
    
}
