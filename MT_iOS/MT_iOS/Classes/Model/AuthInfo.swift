//
//  AuthInfo.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/19.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import LUKeychainAccess

class AuthInfo: NSObject {
    var username = ""
    var password = ""
    var endpoint = ""
    var basicAuthUsername = ""
    var basicAuthPassword = ""
    
    func save() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(username, forKey: "username")
        userDefaults.set(endpoint, forKey: "endpoint")
        userDefaults.set(basicAuthUsername, forKey: "basicAuthUsername")
        userDefaults.synchronize()

        let keychainAccess = LUKeychainAccess.standard()
        keychainAccess?.setString(password, forKey: "password")
        keychainAccess?.setString(basicAuthPassword, forKey: "basicAuthPassword")
    }
    
    func load() {
        var value: String?
        
        let userDefaults = UserDefaults.standard
        value = userDefaults.object(forKey: "username") as? String
        username = (value != nil) ? value! : ""
        value = userDefaults.object(forKey: "endpoint") as? String
        endpoint = (value != nil) ? value! : ""
        value = userDefaults.object(forKey: "basicAuthUsername") as? String
        basicAuthUsername = (value != nil) ? value! : ""

        let keychainAccess = LUKeychainAccess.standard()
        value = keychainAccess?.string(forKey: "password")
        password = (value != nil) ? value! : ""
        value = keychainAccess?.string(forKey: "basicAuthPassword")
        basicAuthPassword = (value != nil) ? value! : ""
    }
    
    func clear() {
        username = ""
        password = ""
        endpoint = ""
        basicAuthUsername = ""
        basicAuthPassword = ""
    }
    
    func logout() {
        self.clear()
        self.save()
    }
}
