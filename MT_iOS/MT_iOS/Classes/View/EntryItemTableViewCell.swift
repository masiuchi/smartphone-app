//
//  EntryItemTableViewCell.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/09.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntryItemTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var visibleButton: UIButton!
    
    let requireIcon = UIImageView(image: UIImage(named: "ico_require"))

    override func awakeFromNib() {
        super.awakeFromNib()
     
        self.contentView.addSubview(requireIcon)
        require = false
    }
    
    var _require: Bool = false
    var require: Bool {
        set {
            _require = newValue
            requireIcon.isHidden = !_require
        }
        get {
            return _require
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate var _item: BaseEntryItem?
    var item: BaseEntryItem? {
        set {
            self._item = newValue
            if self._item != nil {
                self.titleLabel.text = self._item!.label
                self.buttonImage(self._item!.visibled)
                self.require = self._item!.required
            } else {
                self.titleLabel.text = ""
                self.buttonImage(false)
                self.require = false
            }
        }
        get {
            return self._item
        }
    }
    
    func buttonImage(_ visibled: Bool) {
        if visibled {
            self.visibleButton.setImage(UIImage(named: "btn_checked"), for: UIControlState())
        } else {
            self.visibleButton.setImage(UIImage(named: "btn_unchecked"), for: UIControlState())
        }
    }
    
    @IBAction func visibleButtonPushed(_ sender: AnyObject) {
        if let entryItem = self._item {
            entryItem.visibled = !entryItem.visibled
            if !entryItem.isCustomField {
                if entryItem.id == "status" ||
                    entryItem.id == "title" ||
                    entryItem.id == "basename" ||
                    entryItem.id == "body" {
                    entryItem.visibled = true
                }
            } else {
                if entryItem.required {
                    entryItem.visibled = true
                }
            }
            self.buttonImage(self._item!.visibled)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.sizeToFit()
        var rect = requireIcon.frame
        rect.origin.x = self.titleLabel.frame.origin.x + self.titleLabel.frame.width + 8.0
        rect.origin.y = 16.0
        requireIcon.frame = rect
    }
}
