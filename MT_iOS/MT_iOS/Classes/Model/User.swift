//
//  User.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/27.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: BaseObject {
    var displayName: String = ""
    var userpicUrl: String = ""
    var isSuperuser: Bool = false
    
    override init(json: JSON) {
        super.init(json: json)
        
        displayName = json["displayName"].stringValue
        userpicUrl = json["userpicUrl"].stringValue
        isSuperuser = (json["isSuperuser"].stringValue == "true")
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.displayName, forKey: "displayName")
        aCoder.encode(self.userpicUrl, forKey: "userpicUrl")
        aCoder.encode(self.isSuperuser, forKey: "isSuperuser")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.displayName = aDecoder.decodeObject(forKey: "displayName") as! String
        self.userpicUrl = aDecoder.decodeObject(forKey: "userpicUrl") as! String
        self.isSuperuser = aDecoder.decodeBool(forKey: "isSuperuser")
    }

}
