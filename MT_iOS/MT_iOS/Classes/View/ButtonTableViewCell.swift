//
//  ButtonTableViewCell.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/28.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.isUserInteractionEnabled = true
        self.button.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
