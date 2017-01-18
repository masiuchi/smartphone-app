//
//  UploadItemImage.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2016/02/08.
//  Copyright © 2016年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class UploadItemImage: UploadItem {
    var width: CGFloat = Blog.ImageSize.original.size()
    var quality: CGFloat = Blog.ImageQuality.normal.quality() / 100.0
    
}
