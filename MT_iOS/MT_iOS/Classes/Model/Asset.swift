//
//  Asset.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/26.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class Asset: BaseObject {
    var label: String = ""
    var url: String = ""
    var filename: String = ""
    var fileSize: Int = 0
    var width: Int = 0
    var height: Int = 0
    var createdByName: String = ""
    var createdDate: Date?
    var blogID: String = ""
    
    override init(json: JSON) {
        super.init(json: json)
        
        label = json["label"].stringValue
        url = json["url"].stringValue
        filename = json["filename"].stringValue
        if !json["meta"]["fileSize"].stringValue.isEmpty {
            if let int = Int(json["meta"]["fileSize"].stringValue) {
                fileSize = int
            }
        }
        if !json["meta"]["width"].stringValue.isEmpty {
            if let int = Int(json["meta"]["width"].stringValue) {
                width = int
            }
        }
        if !json["meta"]["height"].stringValue.isEmpty {
            if let int = Int(json["meta"]["height"].stringValue) {
                height = int
            }
        }
        createdByName = json["createdBy"]["displayName"].stringValue
        let dateString = json["createdDate"].stringValue
        if !dateString.isEmpty {
            createdDate = Utils.dateTimeFromISO8601String(dateString)
        }
        blogID = json["blog"]["id"].stringValue
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.label, forKey: "label")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.filename, forKey: "filename")
        aCoder.encode(self.fileSize, forKey: "fileSize")
        aCoder.encode(self.width, forKey: "width")
        aCoder.encode(self.height, forKey: "height")
        aCoder.encode(self.createdByName, forKey: "createdByName")
        aCoder.encode(self.createdDate, forKey: "createdDate")
        aCoder.encode(self.blogID, forKey: "blogID")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.label = aDecoder.decodeObject(forKey: "label") as! String
        self.url = aDecoder.decodeObject(forKey: "url") as! String
        self.filename = aDecoder.decodeObject(forKey: "filename") as! String
        self.fileSize = aDecoder.decodeInteger(forKey: "fileSize")
        self.width = aDecoder.decodeInteger(forKey: "width")
        self.height = aDecoder.decodeInteger(forKey: "height")
        self.createdByName = aDecoder.decodeObject(forKey: "createdByName") as! String
        self.createdDate = aDecoder.decodeObject(forKey: "createdDate") as? Date
        self.blogID = aDecoder.decodeObject(forKey: "blogID") as! String
    }
    
    func dispName()-> String {
        if !self.label.isEmpty {
            return self.label
        }
        
        return self.filename
    }
    
    func imageHTML(_ align: Blog.ImageAlign)-> String {
        let dimmensions = "width=\(self.width) height=\(self.height)"
        
        var wrapStyle = "class=\"mt-image-\(align.value().lowercased())\" "
        switch align {
        case .left:
            wrapStyle += "style=\"float: left; margin: 0 20px 20px 0;\""
        case .right:
            wrapStyle += "style=\"float: right; margin: 0 0 20px 20px;\""
        case .center:
            wrapStyle += "style=\"text-align: center; display: block; margin: 0 auto 20px;\""
        default:
            wrapStyle += "style=\"\""
        }
        
        let html = "<img alt=\"\(label)\" src=\"\(url)\" \(dimmensions) \(wrapStyle) />"
        
        return html
    }
}
