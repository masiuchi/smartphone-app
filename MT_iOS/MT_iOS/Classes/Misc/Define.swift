//
//  Define.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/19.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import Foundation

let NOTFOUND = -1
let NOTSELECTED = -1

let MAX_IMAGE_SIZE = 8000

let MTIAssetDeletedNotification = "MTIAssetDeletedNotification"

let HELP_URL = "http://www.movabletype.jp/documentation/mtios/help/"
let LICENSE_URL = "http://www.sixapart.jp/"
let REPORT_BUG_URL = "http://www.movabletype.jp/documentation/mtios/inquiry"

func LOG(_ info: String = "") {
    #if DEBUG
        print("\(info)")
    #endif
}

func LOG_METHOD(_ info: String = "", function: String = #function, file: String = #file, line: Int = #line) {
    #if DEBUG
        let fileName = file.lastPathComponent.stringByDeletingPathExtension
        let sourceInfo = "\(fileName).\(function)-line\(line)"
        print("[\(sourceInfo)]\(info)")
    #endif
}
