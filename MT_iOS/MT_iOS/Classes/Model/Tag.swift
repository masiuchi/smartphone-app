//
//  Tag.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/26.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class Tag: BaseObject {
    var name: String = ""
    
    override init(json: JSON) {
        super.init(json: json)
        
        name = json.stringValue
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.name, forKey: "name")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.name = aDecoder.decodeObject(forKey: "name") as! String
    }

}
