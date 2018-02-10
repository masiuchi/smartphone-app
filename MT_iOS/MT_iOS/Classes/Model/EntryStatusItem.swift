//
//  EntrySegmentedItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntryStatusItem: BaseEntryItem {
    var selected = NOTSELECTED
    var unpublished = false

    override init() {
        super.init()
        
        type = "status"
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.selected, forKey: "selected")
        aCoder.encode(self.unpublished, forKey: "unpublished")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.selected = aDecoder.decodeInteger(forKey: "selected")
        self.unpublished = aDecoder.decodeBool(forKey: "unpublished")
        if self.selected == Entry.Status.unpublish.rawValue {
            self.unpublished = true
        }
    }


    override func value()-> String {
        if selected == NOTSELECTED {
            return ""
        }
        return Entry.Status(rawValue: selected)!.text()
    }
    
    override func dispValue()-> String {
        if selected == NOTSELECTED {
            return ""
        }
        return Entry.Status(rawValue: selected)!.label()
    }
    
    override func makeParams()-> [String : AnyObject] {
        var status = self.value()
        if status.isEmpty {
            status = Entry.Status.draft.text()
        }
        return [self.id:self.value() as AnyObject]
    }
    
    override func clear() {
        selected = NOTSELECTED
    }
}
