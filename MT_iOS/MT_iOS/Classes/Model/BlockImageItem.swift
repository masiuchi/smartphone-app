//
//  BlockImageItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/09.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class BlockImageItem: EntryImageItem {
    var width = 0
    var height = 0
    var align = Blog.ImageAlign.none

    override init() {
        super.init()
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.width, forKey: "width")
        aCoder.encode(self.height, forKey: "height")
        aCoder.encode(self.align.rawValue, forKey: "align")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.width = aDecoder.decodeInteger(forKey: "width")
        self.height = aDecoder.decodeInteger(forKey: "height")
        self.align = Blog.ImageAlign(rawValue: aDecoder.decodeInteger(forKey: "align"))!
    }

    func imageHTML(_ align: Blog.ImageAlign)-> String {
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
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: imageFilename)) {
            var base64 = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
            base64 = base64.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
            
            let src = "data:image/jpeg;base64," + base64
            
            let html = "<img alt=\"\(label)\" src=\"\(src)\" \(wrapStyle) />"
            return html
        }
        
        return ""
    }
    
    override func asHtml()-> String {
        if asset != nil {
            return asset!.imageHTML(align)
        }
        if !imageFilename.isEmpty {
            return self.imageHTML(align)
        }
        return ""
    }
    
    override func value()-> String {
        if url.isEmpty && imageFilename.isEmpty {
            return ""
        }
        
        let html = self.asHtml()
        
        return html
    }
}
