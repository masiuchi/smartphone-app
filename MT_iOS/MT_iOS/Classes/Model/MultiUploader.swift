//
//  MultiUploader.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2016/02/08.
//  Copyright © 2016年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class MultiUploader: NSObject {
    private(set) var items = [UploadItem]()
    private var queue = [UploadItem]()
    private(set) var result: JSON?
    
    var blogID = ""
    var uploadPath = ""

    func addItem(item: UploadItem) {
        item.blogID = self.blogID
        item.uploadPath = self.uploadPath
        items.append(item)
    }
    
    func addAsset(asset: PHAsset, width: CGFloat, quality: CGFloat) {
        let item = UploadItemAsset(asset: asset)
        item.width = width
        item.quality = quality
        self.addItem(item: item)
    }
    
    func addJpeg(path: String, width: CGFloat, quality: CGFloat) {
        let item = UploadItemImageFile(path: path)
        item.width = width
        item.quality = quality
        self.addItem(item: item)
    }
    
    func addImageItem(imageItem: EntryImageItem, blogID: String) {
        if let _ = NSData(contentsOfFile: imageItem.imageFilename) {
            let item = UploadItemImageItem(imageItem: imageItem)
            item.blogID = blogID
            items.append(item)
        }
    }
    
    func addPost(itemList: EntryItemList) {
        let item = UploadItemPost(itemList: itemList)
        item.blogID = itemList.blog.id
        items.append(item)
    }
    
    func addPreview(itemList: EntryItemList) {
        let item = UploadItemPreview(itemList: itemList)
        item.blogID = itemList.blog.id
        items.append(item)
    }
    
    func count()->Int {
        return items.count
    }
    
    func queueCount()->Int {
        return queue.count
    }
    
    func clear() {
        items.removeAll()
    }
    
    func progress()->Float {
        let progress: Float = Float(self.items.count - self.queue.count) / Float(self.items.count)
        return progress
    }
    
    func processed()->Int {
        return self.items.count - self.queue.count
    }
    
    private func upload(progress progressHandler:((UploadItem, Float)->Void)?, success successHandler: ((Int)->Void)?, failure failureHandler: ((Int, JSON)->Void)?) {
        func successFinish() {
            successHandler?(self.processed())
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        func failureFinish(json: JSON) {
            failureHandler?(self.processed(), json)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }

        if let item = self.queue.first {
            item.setup({
                progressHandler?(item, 0.0)

                let progress: ((Double) -> Void) = {
                    (progress: Double) in
                    item.progress = Float(progress)
                    progressHandler?(item, item.progress)
                }
                let success: ((JSON?)-> Void) = {
                    (result: JSON?)-> Void in
                    item.uploaded = true
                    item.progress = 1.0
                    progressHandler?(item, item.progress)
                    self.queue.removeFirst()
                    if self.queue.count == 0 {
                        self.result = result!
                        successFinish()
                    } else {
                        self.upload(progress: progressHandler, success: successHandler, failure: failureHandler)
                    }
                }
                let failure: ((JSON?)-> Void) = {
                    (error: JSON?)-> Void in
                    failureFinish(json: error!)
                }

                item.upload(progress: progress, success: success, failure: failure)
            })
        } else {
            successFinish()
            return
        }
    }
    
    func start(progress:((UploadItem, Float)->Void)?, success: ((Int)->Void)?, failure: ((Int, JSON)->Void)?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.queue = self.items
        self.upload(progress: progress, success:success, failure: failure)
    }

    func restart(progress:((UploadItem, Float)->Void)?, success: ((Int)->Void)?, failure: ((Int, JSON)->Void)?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.upload(progress: progress, success:success, failure: failure)
    }
}
