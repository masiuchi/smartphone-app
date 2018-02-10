//
//  EntryImageItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntryImageItem: EntryAssetItem {
    var imageFilename = ""
    var uploadPath = ""
    var uploadFilename = ""
    
    override init() {
        super.init()
        
        type = "image"
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.imageFilename, forKey: "imageFilename")
        aCoder.encode(self.uploadPath, forKey: "uploadPath")
        aCoder.encode(self.uploadFilename, forKey: "uploadFilename")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let text = aDecoder.decodeObject(forKey: "imageFilename") as? String {
            self.imageFilename = text
        }
        if let text = aDecoder.decodeObject(forKey: "uploadPath") as? String {
            self.uploadPath = text
        }
        if let text = aDecoder.decodeObject(forKey: "uploadFilename") as? String {
            self.uploadFilename = text
        }
    }

    override func asHtml()-> String {
        return super.asHtml()
    }

    override func value()-> String {
        return super.value()
    }
    
    override func dispValue()-> String {
        if !url.isEmpty {
            return url
        }
        
        return imageFilename
    }
    
    func jpegFilename(_ blog: Blog)->String {
        let uuid: String = UUID().uuidString
        let filename = uuid + ".jpeg"
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let user = app.currentUser
        var dir = blog.dataDirPath(user)
        dir = dir.replacingOccurrences(of: ":", with: "", options: [], range: nil)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var path = paths[0].stringByAppendingPathComponent(dir)
        
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
        }
        
        path = path.stringByAppendingPathComponent(filename)
        
        return path
    }

    func removeJpegFile() {
        if !self.imageFilename.isEmpty {
            let path = self.imageFilename
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
            }
            self.imageFilename = ""
        }
    }
    
    override func clear() {
        super.clear()
        self.cleanup()
    }
    
    func cleanup() {
        self.removeJpegFile()
    }
}
