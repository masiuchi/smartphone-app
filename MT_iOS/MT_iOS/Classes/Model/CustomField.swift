//
//  CustomField.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/26.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class CustomField: BaseObject {
    var value: String = ""
    var basename: String = ""
    var descriptionText: String = ""
    var systemObject: String = ""
    var defaultValue: String = ""
    var type: String = ""
    var tag: String = ""
    var required: Bool = false
    var name: String = ""
    var options: String = ""
    
    override init(json: JSON) {
        super.init(json: json)
        
        value = json["value"].stringValue
        basename = json["basename"].stringValue
        descriptionText = json["description"].stringValue
        systemObject = json["systemObject"].stringValue
        defaultValue = json["default"].stringValue
        type = json["type"].stringValue
        tag = json["tag"].stringValue
        required = (json["required"].stringValue == "true")
        name = json["name"].stringValue
        options = json["options"].stringValue
    }

    func isSupportedType()-> Bool {
        let supportedType = [
            "text",
            "textarea",
            "checkbox",
            "url",
            "datetime",
            "select",
            "radio",
            "embed",
            "image",
        ]
        
        return supportedType.contains(self.type)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.value, forKey: "value")
        aCoder.encode(self.basename, forKey: "basename")
        aCoder.encode(self.descriptionText, forKey: "descriptionText")
        aCoder.encode(self.systemObject, forKey: "systemObject")
        aCoder.encode(self.defaultValue, forKey: "defaultValue")
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.tag, forKey: "tag")
        aCoder.encode(self.required, forKey: "required")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.options, forKey: "options")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.value = aDecoder.decodeObject(forKey: "value") as! String
        self.basename = aDecoder.decodeObject(forKey: "basename") as! String
        self.descriptionText = aDecoder.decodeObject(forKey: "descriptionText") as! String
        self.systemObject = aDecoder.decodeObject(forKey: "systemObject") as! String
        self.defaultValue = aDecoder.decodeObject(forKey: "defaultValue") as! String
        self.type = aDecoder.decodeObject(forKey: "type") as! String
        self.tag = aDecoder.decodeObject(forKey: "tag") as! String
        self.required = aDecoder.decodeBool(forKey: "required")
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.options = aDecoder.decodeObject(forKey: "options") as! String
    }

}
