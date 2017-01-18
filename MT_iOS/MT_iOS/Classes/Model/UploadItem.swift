//
//  UploadItem.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2016/02/08.
//  Copyright © 2016年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class UploadItem: NSObject {
    internal(set) var data: Data! = nil
    var blogID = ""
    var uploadPath = ""
    var uploaded = false
    var progress: Float = 0.0
    
    internal(set) var _filename: String = ""
    var filename: String {
        get {
            if self._filename.isEmpty {
                return self.makeFilename()
            }
            return _filename
        }
    }
    
    func setup(_ completion: @escaping (() -> Void)) {
        completion()
    }
    
    func clear() {
        self.data = nil
    }
    
    internal func makeFilename()->String {
        return self._filename
    }
    
    func upload(progress: ((Double) -> Void)? = nil, success: ((JSON?) -> Void)!, failure: ((JSON?) -> Void)!) {
        let api = DataAPI.sharedInstance
        let app = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                let filename = self.makeFilename()
                api.uploadAssetForSite(self.blogID, assetData:  self.data, fileName: filename, options: ["path":self.uploadPath, "autoRenameIfExists":"true"], progress: progress, success: success, failure: failure)
            },
            failure: failure 
        )
    }
    
    func thumbnail(_ size: CGSize, completion: @escaping ((UIImage)->Void)) {
        completion(UIImage())
    }
}
