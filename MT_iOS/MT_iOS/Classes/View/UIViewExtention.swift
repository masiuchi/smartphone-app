//
//  UIViewExtention.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/21.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

extension UIView {
    class func instanceFromNib() -> UIView {
        let className =  NSStringFromClass(self).components(separatedBy: ".").last!
        let view = UINib(nibName: className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        
        return view
    }
}
