//
//  EntryTimeItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntryTimeItem: BaseEntryItem {
    var time: Date?
    
    override init() {
        super.init()
        
        type = "time"
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.time, forKey: "time")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.time = aDecoder.decodeObject(forKey: "time") as? Date
    }
    
    override func value()-> String {
        if let date = self.time {
            let api = DataAPI.sharedInstance
            if api.apiVersion.isEmpty {
                return Utils.dateTimeTextFromDate(date)
            } else {
                let dateTime = Utils.ISO8601StringFromDate(date)
                let comps = dateTime.components(separatedBy: "T")
                return comps[1]
            }
        }
        
        return ""
    }
    
    override func dispValue()-> String {
        if let date = self.time {
            return Utils.timeStringFromDate(date)
        }
        
        return ""
    }
    
    override func makeParams()-> [String : AnyObject] {
        if let _ = self.time {
            return [self.id:self.value() as AnyObject]
        }
        return [self.id:"" as AnyObject]
    }
    
    override func clear() {
        time = nil
    }
}
