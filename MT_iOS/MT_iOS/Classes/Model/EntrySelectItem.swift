//
//  EntrySelectItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntrySelectItem: BaseEntryItem {
    var list = [String]()
    var selected = ""
    
    override init() {
        super.init()
        
        type = "select"
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.list, forKey: "list")
        aCoder.encode(self.selected, forKey: "selected")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.list = aDecoder.decodeObject(forKey: "list") as! [String]
        self.selected = aDecoder.decodeObject(forKey: "selected") as! String
    }

    override func value()-> String {
        if selected.isEmpty || list.count == 0 {
            return ""
        }
        return selected
    }

    override func dispValue()-> String {
        return self.value()
    }

    override func clear() {
        selected = ""
    }
}
