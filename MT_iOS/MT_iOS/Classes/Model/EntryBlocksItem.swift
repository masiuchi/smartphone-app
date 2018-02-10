//
//  EntryBlocksItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/10.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import MMMarkdown

class EntryBlocksItem: EntryTextAreaItem {
    var blocks = [BaseEntryItem]()
    var editMode = Entry.EditMode.richText
   
    override init() {
        super.init()
        
        type = "blocks"
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.blocks, forKey: "blocks")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.blocks = aDecoder.decodeObject(forKey: "blocks") as! [BaseEntryItem]
    }
    
    override func value() -> String {
        var value = ""
        for block in blocks {
            if block is BlockImageItem {
                value += block.value() + "\n\n"
            } else {
                let sourceText = block.value()
                if self.editMode == Entry.EditMode.markdown {
                    if isPreview {
                        do {
                            let markdown = try MMMarkdown.htmlString(withMarkdown: sourceText, extensions: MMMarkdownExtensions.gitHubFlavored)
                            value += markdown + "\n\n"
                        } catch _ {
                            value += sourceText + "\n\n"
                        }
                    } else {
                        value += sourceText + "\n\n"
                    }
                } else {
                    value += "<p>" + sourceText + "</p>" + "\n\n"
                }
            }
        }
        
        return value
    }
    
    override func dispValue()-> String {
        if blocks.count == 0 {
            return ""
        }
        
        if isImageCell() {
            let block = blocks[0] as! BlockImageItem
            if block.asset != nil {
                return block.url
            }
            
            return block.imageFilename
        } else {
            let block = blocks[0] as! BlockTextItem
            return block.text
        }
    }
    
    func isImageCell()-> Bool {
        if blocks.count == 0 {
            return false
        }
        
        let block = blocks[0]
        
        if block is BlockImageItem {
            return true
        }
        
        return false
    }
    
    override func clear() {
        blocks.removeAll(keepingCapacity: false)
    }
}
