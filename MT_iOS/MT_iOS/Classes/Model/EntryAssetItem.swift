//
//  EntryAssetItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/04.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntryAssetItem: BaseEntryItem {
    fileprivate var _asset: Asset?
    var asset: Asset? {
        get {
            return _asset
        }
        set {
            _asset = newValue
            
            if _asset != nil {
                assetID = _asset!.id
                url = _asset!.url
            } else {
                assetID = ""
                url = ""
            }
        }
    }
    
    var url = ""
    var assetID = ""
    var filename = ""
    
    override init() {
        super.init()
        
        type = "asset"
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self._asset, forKey: "_asset")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.assetID, forKey: "assetID")
        aCoder.encode(self.filename, forKey: "filename")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self._asset = aDecoder.decodeObject(forKey: "_asset") as? Asset
        self.url = aDecoder.decodeObject(forKey: "url") as! String
        self.assetID = aDecoder.decodeObject(forKey: "assetID") as! String
        self.filename = aDecoder.decodeObject(forKey: "filename") as! String
    }
    
    func asHtml()-> String {
        return "<a href=\"\(url)\">\(filename)</a>"
    }
    
    override func value()-> String {
        if url.isEmpty {
            return ""
        }
        
        let html = self.asHtml()
        let form = "<form mt:asset-id=\"\(self.assetID)\" class=\"mt-enclosure mt-enclosure-\(self.type)\" style=\"display: inline;\">\(html)</form>"
        
        return form
    }
    
    override func dispValue()-> String {
        return url
    }
    
    override func clear() {
        self.asset = nil
    }
    
    func extractInfoFromHTML(_ html: String) {
        self.url = self.extractURLFromHTML(html)
        self.assetID = self.extractAsssetIDFromHTML(html)
    }

    fileprivate func extractFromHTML(_ html: String, pattern: String)-> String {
        let content: NSString = html as NSString
        let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        if let result = regex?.firstMatch(in: content as String, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, content.length)) {
            if result.numberOfRanges < 1 {
                return ""
            }
            let range = result.rangeAt(1)
            let text = content.substring(with: range)
            return text
        } else {
            return ""
        }
    }
    
    fileprivate func extractURLFromHTML(_ html: String)-> String {
        return self.extractFromHTML(html, pattern: "<a href=\"([^\"]*)\">")
    }
    
    fileprivate func extractAsssetIDFromHTML(_ html: String)-> String {
        return self.extractFromHTML(html, pattern: "<form mt:asset-id=\"([^\"]*)\" ")
    }
    
    override func makeParams()-> [String : AnyObject] {
        return [self.id:self.value() as AnyObject]
    }
}
