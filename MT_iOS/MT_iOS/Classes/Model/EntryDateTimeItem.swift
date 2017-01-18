//
//  EntryDateTimeItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntryDateTimeItem: BaseEntryItem {
    var datetime: Date?
    
    override init() {
        super.init()
        
        type = "datetime"
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.datetime, forKey: "datetime")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.datetime = aDecoder.decodeObject(forKey: "datetime") as? Date
    }

    override func value()-> String {
        if let date = self.datetime {
            let api = DataAPI.sharedInstance
            if api.apiVersion.isEmpty {
                return Utils.dateTimeTextFromDate(date)
            } else {
                let dateTime = Utils.ISO8601StringFromDate(date)
                return dateTime
            }
        }
        
        return ""
    }
    
    override func dispValue()-> String {
        if let date = self.datetime {
            return Utils.dateTimeFromDate(date)
        }
        
        return ""
    }
    
    override func makeParams()-> [String : AnyObject] {
        if let _ = self.datetime {
            return [self.id:self.value() as AnyObject]
        }
        return [self.id:"" as AnyObject]
    }
    
    override func clear() {
        datetime = nil
    }

}
