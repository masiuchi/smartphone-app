//
//  BaseObject.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/19.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class BaseObject: NSObject, NSCoding {
    var id: String = ""
    var assets = [Asset]()
    
    init(json: JSON) {
        super.init()
        
        id = json["id"].stringValue
        
        assets.removeAll(keepingCapacity: false)
        for item in json["assets"].arrayValue {
            let asset = Asset(json: item)
            assets.append(asset)
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.assets, forKey: "assets")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        if let object: AnyObject = aDecoder.decodeObject(forKey: "assets") as AnyObject? {
            self.assets = object as! [Asset]
        }
    }
}
