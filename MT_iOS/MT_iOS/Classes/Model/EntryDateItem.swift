//
//  EntryDateItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntryDateItem: BaseEntryItem {
    var date: Date?
    
    override init() {
        super.init()
        
        type = "date"
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.date, forKey: "date")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.date = aDecoder.decodeObject(forKey: "date") as? Date
    }

    override func value()-> String {
        if let date = self.date {
            let api = DataAPI.sharedInstance
            if api.apiVersion.isEmpty {
                return Utils.dateTimeTextFromDate(date)
            } else {
                let dateTime = Utils.ISO8601StringFromDate(date)
                let comps = dateTime.components(separatedBy: "T")
                return comps[0]
            }
        }
        
        return ""
    }
    
    override func dispValue()-> String {
        if let date = self.date {
            return Utils.dateStringFromDate(date)
        }
        
        return ""
    }

    override func makeParams()-> [String : AnyObject] {
        if let _ = self.date {
            return [self.id:self.value() as AnyObject]
        }
        return [self.id:"" as AnyObject]
    }
    
    override func clear() {
        date = nil
    }
}
