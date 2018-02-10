//
//  BaseEntry.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/22.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class BaseEntry: BaseObject {
    enum Status: Int {
        case publish = 0,
        draft,
        future,
        unpublish
        
        func text()-> String {
            switch(self) {
            case .publish:
                return "Publish"
            case .draft:
                return "Draft"
            case .future:
                return "Future"
            case .unpublish:
                return "Unpublish"
            }
        }

        func label()-> String {
            switch(self) {
            case .publish:
                return NSLocalizedString("Publish", comment: "Publish")
            case .draft:
                return NSLocalizedString("Draft", comment: "Draft")
            case .future:
                return NSLocalizedString("Future", comment: "Future")
            case .unpublish:
                return NSLocalizedString("Unpublish", comment: "Unpublish")
            }
        }
    }

    enum EditMode: Int {
        case plainText = 0,
        richText,
        markdown
        
        func text()-> String {
            switch(self) {
            case .plainText:
                return "PlainText"
            case .richText:
                return "RichText"
            case .markdown:
                return "Markdown"
            }
        }
        
        func label()-> String {
            switch(self) {
            case .plainText:
                return NSLocalizedString("PlainText", comment: "PlainText")
            case .richText:
                return NSLocalizedString("RichText", comment: "RichText")
            case .markdown:
                return NSLocalizedString("Markdown", comment: "Markdown")
            }
        }

        func format()-> String {
            switch(self) {
            case .plainText:
                return "0"
            case .richText:
                return "richtext"
            case .markdown:
                return "markdown"
            }
        }
    }
    
    var title = ""
    var date: Date?
    var modifiedDate: Date?
    var unpublishedDate: Date?
    var status = ""
    var blogID = ""
    var body = ""
    var more = ""
    var excerpt = ""
    var keywords = ""
    var tags = [Tag]()
    var author: Author!
    var customFields = [CustomField]()
    var permalink = ""
    var basename = ""
    var format = ""
    
    var editMode: EditMode = .richText

    override init(json: JSON) {
        super.init(json: json)
        
        title = json["title"].stringValue
        let dateString = json["date"].stringValue
        if !dateString.isEmpty {
            date = Utils.dateTimeFromISO8601String(dateString)
        }
        let modifiedDateString = json["modifiedDate"].stringValue
        if !modifiedDateString.isEmpty {
            modifiedDate = Utils.dateTimeFromISO8601String(modifiedDateString)
        }
        let unpublishedDateString = json["unpublishedDate"].stringValue
        if !unpublishedDateString.isEmpty {
            unpublishedDate = Utils.dateTimeFromISO8601String(unpublishedDateString)
        }
        status = json["status"].stringValue
        blogID = json["blog"]["id"].stringValue
        body = json["body"].stringValue
        more = json["more"].stringValue
        excerpt = json["excerpt"].stringValue
        keywords = json["keywords"].stringValue
        basename = json["basename"].stringValue
        
        tags.removeAll(keepingCapacity: false)
        for item in json["tags"].arrayValue {
            let tag = Tag(json: item)
            tags.append(tag)
        }
        
        customFields.removeAll(keepingCapacity: false)
        for item in json["customFields"].arrayValue {
            let customField = CustomField(json: item)
            customFields.append(customField)
        }
        
        author = Author(json: json["author"])

        permalink = json["permalink"].stringValue

        format = json["format"].stringValue
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.date, forKey: "date")
        aCoder.encode(self.modifiedDate, forKey: "modifiedDate")
        aCoder.encode(self.unpublishedDate, forKey: "unpublishedDate")
        aCoder.encode(self.status, forKey: "status")
        aCoder.encode(self.blogID, forKey: "blogID")
        aCoder.encode(self.excerpt, forKey: "excerpt")
        aCoder.encode(self.keywords, forKey: "keywords")
        aCoder.encode(self.tags, forKey: "tags")
        aCoder.encode(self.author, forKey: "author")
        aCoder.encode(self.customFields, forKey: "customFields")
        aCoder.encode(self.permalink, forKey: "permalink")
        aCoder.encode(self.basename, forKey: "basename")
        aCoder.encode(self.format, forKey: "format")
        aCoder.encode(self.editMode.rawValue, forKey: "editMode")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.date = aDecoder.decodeObject(forKey: "date") as? Date
        self.modifiedDate = aDecoder.decodeObject(forKey: "modifiedDate") as? Date
        self.unpublishedDate = aDecoder.decodeObject(forKey: "unpublishedDate") as? Date
        self.status = aDecoder.decodeObject(forKey: "status") as! String
        self.blogID = aDecoder.decodeObject(forKey: "blogID") as! String
        self.excerpt = aDecoder.decodeObject(forKey: "excerpt") as! String
        self.keywords = aDecoder.decodeObject(forKey: "keywords") as! String
        self.tags = aDecoder.decodeObject(forKey: "tags") as! [Tag]
        self.author = aDecoder.decodeObject(forKey: "author") as! Author
        self.customFields = aDecoder.decodeObject(forKey: "customFields") as! [CustomField]
        self.permalink = aDecoder.decodeObject(forKey: "permalink") as! String
        self.basename = aDecoder.decodeObject(forKey: "basename") as! String
        if let object: AnyObject = aDecoder.decodeObject(forKey: "format") as AnyObject? {
            self.format = object as! String
        }
        self.editMode = BaseEntry.EditMode(rawValue: aDecoder.decodeInteger(forKey: "editMode"))!
    }
    
    func tagsString()-> String {
        var array = [String]()
        for tag in tags {
            array.append(tag.name)
        }
        
        return array.joined(separator: ",")
    }
    
    func setTagsFromString(_ string: String) {
        tags.removeAll(keepingCapacity: false)
        let list = string.characters.split { $0 == "," }.map { String($0) }
        for item in list {
            tags.append(Tag(json: JSON(item)))
        }
    }
    
    func customFieldWithBasename(_ basename: String)-> CustomField? {
        for field in customFields {
            if field.basename == basename {
                return field
            }
        }
        
        return nil
    }
}
