//
//  EntrycCheckboxItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntryCheckboxItem: BaseEntryItem {
    var checked = false
    
    override init() {
        super.init()
        
        type = "checkbox"
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.checked, forKey: "checked")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.checked = aDecoder.decodeBool(forKey: "checked")
    }
    
    override func value()-> String {
        return checked ? "1" : "0"
    }
    
    override func dispValue()-> String {
        return checked ? "true" : "false"
    }
    
    override func clear() {
        checked = false
    }
}
