//
//  UploadItemAsset.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2016/02/08.
//  Copyright © 2016年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class UploadItemAsset: UploadItemImage {
    fileprivate(set) var asset: PHAsset!
    
    init(asset: PHAsset) {
        super.init()
        self.asset = asset
    }
    
    override func setup(_ completion: @escaping (() -> Void)) {
        let manager = PHImageManager.default()
        manager.requestImageData(for: self.asset, options: nil,
            resultHandler: {(imageData: Data?, dataUTI: String?, orientation: UIImageOrientation, info: [AnyHashable: Any]?) in
                if let data = imageData {
                    if let image = UIImage(data: data) {
                        let jpeg = Utils.convertJpegData(image, width: self.width, quality: self.quality)
                        self.data = jpeg
                        completion()
                    }
                } else {
                    completion()
                }
            }
        )
    }
    
    override func thumbnail(_ size: CGSize, completion: @escaping ((UIImage)->Void)) {
        let manager = PHImageManager.default()
        manager.requestImage(for: self.asset, targetSize: size, contentMode: PHImageContentMode(rawValue: 0)!, options: nil,
            resultHandler: {image, Info in
                if let image = image {
                    completion(image)
                }
            }
        )
    }
    
    override func makeFilename()->String {
        if let date = asset.creationDate {
            self._filename =  Utils.makeJPEGFilename(date)
        } else {
            self._filename = Utils.makeJPEGFilename(Date())
        }
        
        return self._filename
    }

}
