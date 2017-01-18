//
//  CategoryTableViewCell.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/08.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    fileprivate var _object: Category?
    var object: Category? {
        set {
            self._object = newValue
            
            if newValue != nil {
                self.textLabel?.text = self._object!.label
            } else {
                self.textLabel?.text = ""
            }
        }
        get {
            return self._object
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if object != nil {
            let indentPoints = CGFloat(object!.level) * 20.0;
        
            self.contentView.frame = CGRect(x: indentPoints,
                y: self.contentView.frame.origin.y,
                width: self.contentView.frame.size.width - indentPoints,
                height: self.contentView.frame.size.height);
        }
    }
    
}
