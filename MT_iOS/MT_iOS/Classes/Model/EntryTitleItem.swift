//
//  EntryTitleItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/04.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntryTitleItem: EntryTextItem {
    override init() {
        super.init()

        type = "title"
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
