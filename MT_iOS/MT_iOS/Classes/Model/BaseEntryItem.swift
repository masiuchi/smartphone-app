//
//  BaseEntryItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class BaseEntryItem: NSObject, NSCoding {
    var id = ""
    var type = ""
    var label = ""
    var descriptionText = ""
    var isCustomField = false
    var visibled = true
    var disabled = false
    var required = false
    var isDirty = false
    
    var isPreview = false

    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.label, forKey: "label")
        aCoder.encode(self.descriptionText, forKey: "descriptionText")
        aCoder.encode(self.isCustomField, forKey: "isCustomField")
        aCoder.encode(self.visibled, forKey: "visibled")
        aCoder.encode(self.disabled, forKey: "disabled")
        aCoder.encode(self.required, forKey: "required")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.type = aDecoder.decodeObject(forKey: "type") as! String
        self.label = aDecoder.decodeObject(forKey: "label") as! String
        if let object = aDecoder.decodeObject(forKey: "descriptionText") as? String {
            self.descriptionText = object
        }
        self.isCustomField = aDecoder.decodeBool(forKey: "isCustomField")
        self.visibled = aDecoder.decodeBool(forKey: "visibled")
        self.disabled = aDecoder.decodeBool(forKey: "disabled")
        self.required = aDecoder.decodeBool(forKey: "required")
    }

    func value()-> String {
        return ""
    }

    func dispValue()-> String {
        return self.value()
    }
    
    func makeParams()-> [String:AnyObject] {
        return [self.id:self.value() as AnyObject]
    }
    
    func clear() {
        
    }
}
