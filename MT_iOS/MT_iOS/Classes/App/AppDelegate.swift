//
//  AppDelegate.swift
//  Movable Type for iOS
//
//  Created by CHEEBOW on 2015/05/18.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var authInfo = AuthInfo()
    var currentUser: User?
    
    fileprivate func initAppearance() {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        UINavigationBar.self.appearance().isTranslucent = false
        UINavigationBar.self.appearance().barTintColor = Color.navBar
        UINavigationBar.self.appearance().tintColor = Color.navBarTint
        UINavigationBar.self.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Color.navBarTitle];
        
        SVProgressHUD.setBackgroundColor(UIColor.black)
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.initAppearance()
        
        let api = DataAPI.sharedInstance
        api.clientID = "MTiOS"
        
        authInfo.load()
        
        if authInfo.username.isEmpty || authInfo.password.isEmpty || authInfo.endpoint.characters.count < 8 {
            self.goLoginView()
        } else {
            if Utils.hasConnectivity() {
                Utils.performAfterDelay(
                    {
                        self.signIn(self.authInfo, showHud: false)
                    },
                    delayTime: 0.2
                )
            } else {
                self.goLoginView()
                SVProgressHUD.showError(withStatus: NSLocalizedString("You can not connect to the network.", comment: "You can not connect to the network."))
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: -
    fileprivate func goLoginView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
    
    fileprivate func goBlogList() {
        let storyboard: UIStoryboard = UIStoryboard(name: "BlogList", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
    
    func getUser(_ auth: AuthInfo, showHud: Bool){
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            LOG("failure:\(error!.description)")
            if showHud {
                SVProgressHUD.showError(withStatus: error!["message"].stringValue)
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            Utils.performAfterDelay(
                {
                    self.goLoginView()
                },
                delayTime: 2.0
            )
        }

        let api = DataAPI.sharedInstance
        api.authenticationV2(auth.username, password: auth.password, remember: true,
            success:{_ in
                api.getUser("me",
                    success: {(user: JSON?)-> Void in
                        LOG("\(user!)")
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if showHud {
                            SVProgressHUD.dismiss()
                        }
                        
                        self.currentUser = User(json: user!)
                        
                        self.goBlogList()
                    },
                    failure: failure
                )
            },
            failure: failure
        )
    }
    
    func signIn(_ auth: AuthInfo, showHud: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if showHud {
            SVProgressHUD.show(withStatus: NSLocalizedString("Sign In...", comment: "Sign In..."))
        }
        let api = DataAPI.sharedInstance
        api.APIBaseURL = auth.endpoint
        api.basicAuth.username = auth.basicAuthUsername
        api.basicAuth.password = auth.basicAuthPassword
        
        self.authInfo = auth
        self.authInfo.save()
        
        api.version(
            success: {_ in
                self.getUser(auth, showHud: showHud)
            },
            failure: {_ in
                api.endpointVersion = "v2"
                self.getUser(auth, showHud: showHud)
            }
        )
    }
    
    fileprivate func postLogout() {
        let api = DataAPI.sharedInstance
        api.resetAuth()
        
        let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let authInfo = app.authInfo
        authInfo.logout()
        
        self.goLoginView()
    }

    func logout() {
        let api = DataAPI.sharedInstance
        
        if api.sessionID.isEmpty {
            self.goLoginView()
            return
        }
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Logout...", comment: "Logout..."))
        api.revokeAuthentication(
            {_ in
                SVProgressHUD.dismiss()
                self.postLogout()
            },
            failure: {(error: JSON?)-> Void in
                SVProgressHUD.dismiss()
                self.postLogout()
            }
        )
    }
    
    func createEntry(_ blog: Blog, controller: UIViewController) {
        let vc = EntryDetailTableViewController()
        vc.object = Entry(json: ["id":"", "status":"Draft"])
        vc.object.date = Date()
        vc.blog = blog
        vc.object.editMode = blog.editorMode
        let nav = UINavigationController(rootViewController: vc)
        controller.present(nav, animated: true, completion:
            {_ in
                vc.title = NSLocalizedString("Create entry", comment: "Create entry")
            }
        )
    }

    func createPage(_ blog: Blog, controller: UIViewController) {
        let vc = PageDetailTableViewController()
        vc.object = Page(json: ["id":"", "status":"Draft"])
        vc.object.date = Date()
        vc.blog = blog
        vc.object.editMode = blog.editorMode
        let nav = UINavigationController(rootViewController: vc)
        vc.title = NSLocalizedString("Create page", comment: "Create page")
        controller.present(nav, animated: true, completion:
            {_ in
                vc.title = NSLocalizedString("Create page", comment: "Create page")
            }
        )
    }
}

extension String {
    
    var lastPathComponent: String {
            
        get {
            return (self as NSString).lastPathComponent
        }
    }

    var pathExtension: String {
            
        get {
            return (self as NSString).pathExtension
        }
    }
    
    var stringByDeletingLastPathComponent: String {

        get {
            return (self as NSString).deletingLastPathComponent
        }
    }
    
    var stringByDeletingPathExtension: String {
            
        get {
            return (self as NSString).deletingPathExtension
        }
    }
    
    var pathComponents: [String] {
            
        get {
            return (self as NSString).pathComponents
        }
    }
        
    func stringByAppendingPathComponent(_ path: String) -> String {
            
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
        
    func stringByAppendingPathExtension(_ ext: String) -> String? {
            
        let nsSt = self as NSString
        return nsSt.appendingPathExtension(ext)
    }
}


