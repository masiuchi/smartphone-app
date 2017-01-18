//
//  UploadItemImageFile.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2016/02/08.
//  Copyright © 2016年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class UploadItemImageFile: UploadItemImage {
    fileprivate(set) var path: String!

    init(path: String) {
        super.init()
        self.path = path
    }

    override func setup(_ completion: @escaping (() -> Void)) {
        if let image = UIImage(contentsOfFile: self.path) {
            let jpeg = Utils.convertJpegData(image, width: self.width, quality: self.quality)
            self.data = jpeg
            completion()
        } else {
            completion()
        }
    }
    
    override func thumbnail(_ size: CGSize, completion: @escaping ((UIImage)->Void)) {
        if let image = UIImage(contentsOfFile: path) {
            let widthRatio = size.width / image.size.width
            let heightRatio = size.height / image.size.height
            let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
            let resizedSize = CGSize(width: (image.size.width * ratio), height: (image.size.height * ratio))
            UIGraphicsBeginImageContext(resizedSize)
            image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            completion(resizedImage!)
        }
    }
    
    override func makeFilename()->String {
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: path)
            if let date = attributes[FileAttributeKey.creationDate] as? Date {
                self._filename = Utils.makeJPEGFilename(date)
            } else {
                self._filename = Utils.makeJPEGFilename(Date())
            }
        } catch _ {
            self._filename = Utils.makeJPEGFilename(Date())
        }
        
        return self._filename
    }
}
