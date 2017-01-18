//
//  Page.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/22.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class Page: BaseEntry {
    var folders = [Folder]()
    
    override init(json: JSON) {
        super.init(json: json)
        
        folders.removeAll(keepingCapacity: false)
        let folder = Folder(json: json["folder"])
        folders.append(folder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.folders, forKey: "folders")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.folders = aDecoder.decodeObject(forKey: "folders") as! [Folder]
    }

}
