//
//  Blog.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/19.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class UploadDestination: BaseObject {
    var path: String = ""
    var raw: String = ""
    
    override init(json: JSON) {
        super.init(json: json)
        
        path = json["path"].stringValue
        raw = json["raw"].stringValue
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.path, forKey: "path")
        aCoder.encode(self.raw, forKey: "raw")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.path = aDecoder.decodeObject(forKey: "path") as! String
        self.raw = aDecoder.decodeObject(forKey: "raw") as! String
    }
}

class Blog: BaseObject {
    enum ImageSize: Int {
        case original = 0
        ,xl
        ,l
        ,m
        ,s
        ,xs
        ,custom
        ,_Num
        
        func size()-> CGFloat {
            switch(self) {
            case .original:
                return 0
            case .xl:
                return 1280.0
            case .l:
                return 1024.0
            case .m:
                return 800.0
            case .s:
                return 640.0
            case .xs:
                return 320.0
            case .custom:
                return 0.0
            case ._Num:
                return 0
            }
        }
        func pix()-> String {
            switch(self) {
            case .original:
                return NSLocalizedString("Original Size", comment: "Original Size")
            case .xl:
                return "1280px"
            case .l:
                return "1024px"
            case .m:
                return "800px"
            case .s:
                return "640px"
            case .xs:
                return "320px"
            case .custom:
                return ""
            case ._Num:
                return ""
            }
        }
        func label()-> String {
            switch(self) {
            case .original:
                return NSLocalizedString("Original", comment: "Original")
            case .xl:
                return NSLocalizedString("X-Large", comment: "X-Large")
            case .l:
                return NSLocalizedString("Large", comment: "Large")
            case .m:
                return NSLocalizedString("Medium", comment: "Medium")
            case .s:
                return NSLocalizedString("Small", comment: "Small")
            case .xs:
                return NSLocalizedString("X-Small", comment: "X-Small")
            case .custom:
                return NSLocalizedString("Custom", comment: "Custom")
            case ._Num:
                return ""
            }
        }
    }

    enum ImageQuality: Int {
        case highest = 0
        ,high
        ,normal
        ,low
        ,_Num
        
        func quality()-> CGFloat {
            switch(self) {
            case .highest:
                return 100.0
            case .high:
                return 80.0
            case .normal:
                return 50.0
            case .low:
                return 30.0
            case ._Num:
                return 0.0
            }
        }
        func label()-> String {
            switch(self) {
            case .highest:
                return NSLocalizedString("Super Fine", comment: "Super Fine")
            case .high:
                return NSLocalizedString("Fine", comment: "Fine")
            case .normal:
                return NSLocalizedString("Normal", comment: "Normal")
            case .low:
                return NSLocalizedString("Low", comment: "Low")
            case ._Num:
                return ""
            }
        }
    }
    
    enum ImageAlign: Int {
        case none = 0,
        left,
        right,
        center,
        _Num
        
        func value()-> String {
            switch(self) {
            case .none:
                return "none"
            case .left:
                return "left"
            case .right:
                return "right"
            case .center:
                return "center"
            case ._Num:
                return "none"
            }
        }

        func label()-> String {
            switch(self) {
            case .none:
                return NSLocalizedString("None", comment: "None")
            case .left:
                return NSLocalizedString("Left", comment: "Left")
            case .right:
                return NSLocalizedString("Right", comment: "Right")
            case .center:
                return NSLocalizedString("Center", comment: "Center")
            case ._Num:
                return ""
            }
        }
    }
    
    var name: String = ""
    var url: String = ""
    var parentName: String = ""
    var parentID: String = ""
    
    var allowToChangeAtUpload = true
    var uploadDestination: UploadDestination!

    var permissions: [String] = []
    var customfieldsForEntry: [CustomField] = []
    var customfieldsForPage: [CustomField] = []
    
    var uploadDir: String = "/"
    var imageSize: ImageSize = .m
    var imageQuality: ImageQuality = .normal
    var imageAlign: ImageAlign = .none
    var imageCustomWidth = 0
    var editorMode: BaseEntry.EditMode = .richText
    
    var endpoint = ""
    
    override init(json: JSON) {
        super.init(json: json)
        
        name = json["name"].stringValue
        url = json["url"].stringValue
        parentName = json["parent"]["name"].stringValue
        parentID = json["parent"]["id"].stringValue
        
        if !json["allowToChangeAtUpload"].stringValue.isEmpty {
            allowToChangeAtUpload = (json["allowToChangeAtUpload"].stringValue == "true")
        }
        uploadDestination = UploadDestination(json: json["uploadDestination"])
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.parentName, forKey: "parentName")
        aCoder.encode(self.parentID, forKey: "parentID")
        aCoder.encode(self.allowToChangeAtUpload, forKey: "allowToChangeAtUpload")
        aCoder.encode(self.uploadDestination, forKey: "uploadDestination")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.url = aDecoder.decodeObject(forKey: "url") as! String
        if let object: AnyObject = aDecoder.decodeObject(forKey: "parentName") as AnyObject? {
            self.parentName = object as! String
        }
        if let object: AnyObject = aDecoder.decodeObject(forKey: "parentID") as AnyObject? {
            self.parentID = object as! String
        }
        if let object: AnyObject = aDecoder.decodeObject(forKey: "allowToChangeAtUpload") as AnyObject? {
            self.allowToChangeAtUpload = object as! Bool
        }
        if let object: AnyObject = aDecoder.decodeObject(forKey: "uploadDestination") as AnyObject? {
            self.uploadDestination = object as! UploadDestination
        }
    }

    //MARK: - Permissions
    func hasPermission(_ permission: String)-> Bool {
        return permissions.contains(permission)
    }
    
    func canCreateEntry(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("create_post")
    }

    func canUpdateEntry(user: User, entry: Entry)-> Bool {
        if user.isSuperuser { return true }
        if self.hasPermission("edit_all_posts") {
            return true
        }
        
        if self.hasPermission("publish_post") {
            if entry.author.id == user.id {
                return true
            }
        }
        
        if self.hasPermission("create_post") {
            if entry.author.id == user.id {
                if entry.status == "Draft" {
                    return true
                }
            }
        }

        return false
    }
    
    func canDeleteEntry(user: User, entry: Entry)-> Bool {
        if user.isSuperuser { return true }
        if self.hasPermission("edit_all_posts") {
            return true
        }
        
        if self.hasPermission("create_post") {
            if entry.author.id == user.id {
                if entry.status == "Draft" {
                    return true
                }
            }
        }
        
        return false
    }
    
    func canPublishEntry(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("publish_post")
    }
    
    func canCreateCategory(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("edit_categories")
    }

    func canCreatePage(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("manage_pages")
    }

    func canUpdatePage(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("manage_pages")
    }

    func canDeletePage(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("manage_pages")
    }

    func canListAsset(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("edit_assets")
    }
    
    func canDeleteAsset(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("edit_assets")
    }
    
    func canListAssetForEntry(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("create_post") || self.hasPermission("edit_all_posts")
    }

    func canListAssetForPage(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("manage_pages")
    }
    
    func canUpload(user: User)-> Bool {
        if user.isSuperuser { return true }
        return self.hasPermission("upload")
    }
    
    //MARK: - Settings
    func settingKey(_ name: String, user: User? = nil)-> String {
        if user != nil {
            return self.endpoint + "_blog\(id)_user\(user!.id)_\(name)"
        }
        return self.endpoint + "_blog\(id)_\(name)"
    }
    
    func dataDirPath(_ user: User? = nil)-> String {
        var dir = self.endpoint + "_blog\(id)"
        if user != nil {
            dir = self.endpoint + "_blog\(id)_user\(user!.id)"
        }
        dir = dir.replacingOccurrences(of: "/", with: "_", options: [], range: nil)
        
        return dir
    }
    
    func renameOldDataDir(_ user: User) {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let oldDir = self.dataDirPath()
        let oldPath = paths[0].stringByAppendingPathComponent(oldDir)
        let newDir = self.dataDirPath(user)
        let newPath = paths[0].stringByAppendingPathComponent(newDir)
        if fileManager.fileExists(atPath: oldPath) {
            do {
                try fileManager.moveItem(atPath: oldPath, toPath: newPath)
            } catch {
            }
        }
    }
    
    func draftDirPath(_ object: BaseEntry, user: User? = nil)-> String {
        var path = self.dataDirPath(user)
        path = path.stringByAppendingPathComponent(object is Entry ? "draft_entry" : "draft_page")
        
        return path
    }
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        let app = UIApplication.shared.delegate as! AppDelegate
        if let user = app.currentUser {
            if let value: AnyObject = defaults.object(forKey: self.settingKey("blogsettings_uploaddir", user: user)) as AnyObject? {
                uploadDir = value as! String
            }
            if let value: Int = defaults.object(forKey: self.settingKey("blogsettings_imagesize", user: user)) as? Int {
                imageSize = Blog.ImageSize(rawValue: value)!
            }
            if let value: Int = defaults.object(forKey: self.settingKey("blogsettings_imagequality", user: user)) as? Int {
                imageQuality = Blog.ImageQuality(rawValue: value)!
            }
            if let value: Int = defaults.object(forKey: self.settingKey("blogsettings_imagecustomwidth", user: user)) as? Int {
                imageCustomWidth = value
            }
            if let value: Int = defaults.object(forKey: self.settingKey("blogsettings_editormode", user: user)) as? Int {
                editorMode = Entry.EditMode(rawValue: value)!
            }
        }

        //V1.0.xとの互換性のため
        var saveFlag = false
        if let value: AnyObject = defaults.object(forKey: self.settingKey("blogsettings_uploaddir")) as AnyObject? {
            uploadDir = value as! String
            defaults.removeObject(forKey: self.settingKey("blogsettings_uploaddir"))
            saveFlag = true
        }
        if let value: Int = defaults.object(forKey: self.settingKey("blogsettings_imagesize")) as? Int {
            imageSize = Blog.ImageSize(rawValue: value)!
            defaults.removeObject(forKey: self.settingKey("blogsettings_imagesize"))
            saveFlag = true
        }
        if let value: Int = defaults.object(forKey: self.settingKey("blogsettings_imagequality")) as? Int {
            imageQuality = Blog.ImageQuality(rawValue: value)!
            defaults.removeObject(forKey: self.settingKey("blogsettings_imagequality"))
            saveFlag = true
        }

        if saveFlag {
            self.saveSettings()
        }
        
        return
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        let app = UIApplication.shared.delegate as! AppDelegate
        if let user = app.currentUser {
            defaults.set(uploadDir, forKey:self.settingKey("blogsettings_uploaddir", user: user))
            defaults.set(imageSize.rawValue, forKey:self.settingKey("blogsettings_imagesize", user: user))
            defaults.set(imageQuality.rawValue, forKey:self.settingKey("blogsettings_imagequality", user: user))
            defaults.set(imageCustomWidth, forKey:self.settingKey("blogsettings_imagecustomwidth", user: user))
            defaults.set(editorMode.rawValue, forKey:self.settingKey("blogsettings_editormode", user: user))
            defaults.synchronize()
        }
    }
    
    //MARK: -
    func adjustUploadDestination() {
        //なにもしない
    }
    /*
    func adjustUploadDestination() {
        func setDestination(destination: UploadDestination) {
            if !destination.raw.isEmpty {
                self.uploadDir = destination.raw
            } else {
                self.uploadDir = "/"
            }
            self.saveSettings()
        }
        
        if let uploadDestination = self.uploadDestination {
            if allowToChangeAtUpload {
                if self.uploadDir == "/" || self.uploadDir.isEmpty {
                    setDestination(uploadDestination)
                } else {
                    //MTiOSの設定有効
                }
            } else {
                setDestination(uploadDestination)
            }
        } else {
            //MTiOSの設定有効
        }
        
        if  self.uploadDir.isEmpty {
            self.uploadDir = "/"
        }
    }
    */
    
}
