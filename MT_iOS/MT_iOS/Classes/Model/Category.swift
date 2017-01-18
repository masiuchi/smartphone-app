//
//  Category.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/26.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class Category: BaseObject {
    var label: String = ""
    var basename: String = ""
    var parent: String = ""
    
    var level = 0
    var path: String = ""
    
    override init(json: JSON) {
        super.init(json: json)
        
        label = json["label"].stringValue
        basename = json["basename"].stringValue
        parent = json["parent"].stringValue
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.label, forKey: "label")
        aCoder.encode(self.basename, forKey: "basename")
        aCoder.encode(self.parent, forKey: "parent")
        aCoder.encode(self.level, forKey: "level")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.label = aDecoder.decodeObject(forKey: "label") as! String
        self.basename = aDecoder.decodeObject(forKey: "basename") as! String
        self.parent = aDecoder.decodeObject(forKey: "parent") as! String
        self.level = aDecoder.decodeInteger(forKey: "level")
    }

}
