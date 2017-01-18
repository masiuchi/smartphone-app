//
//  BlogTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/21.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class BlogTableViewController: BaseTableViewController {
    enum Section:Int {
        case blog = 0,
        asset,
        _Num
    }
    
    enum BlogItem:Int {
        case entries = 0,
        draftEntries,
        pages,
        draftPages,
        _Num
    }

    enum AssetItem:Int {
        case assets = 0,
        _Num
    }

    var blog: Blog!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = blog.name
        self.tableView.backgroundColor = Color.tableBg

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.show(withStatus: NSLocalizedString("Get blog settings...", comment: "Get blog settings..."))
        self.getPermissions(
            {(failure: Bool)-> Void in
                let user = (UIApplication.shared.delegate as! AppDelegate).currentUser!
                if self.blog.canCreateEntry(user: user) || self.blog.canCreatePage(user: user) {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_newentry"), left: false, target: self, action: #selector(BlogTableViewController.composeButtonPushed(_:)))
                } else {
                    self.navigationItem.rightBarButtonItem = nil
                }

                self.tableView.reloadData()

                self.getCustomFields(
                    {(failure: Bool)-> Void in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if !failure {
                            SVProgressHUD.dismiss()
                        }
                    }
                )
            }
        )
        
        //V1.0.xとの互換性のため
        let app = UIApplication.shared.delegate as! AppDelegate
        if let user = app.currentUser {
            self.blog.renameOldDataDir(user)
        }
    }
    
    fileprivate func getCustomFields(_ completion: @escaping (Bool)-> Void) {
        let api = DataAPI.sharedInstance
        let app = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
        
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            LOG("failure:\(error!.description)")
            SVProgressHUD.showError(withStatus: error!["message"].stringValue)
            completion(true)
        }
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                let params = ["includeShared":"system", "systemObject":"entry"]
                api.listFields(siteID: self.blog.id, options: params, success:
                    {(result: [JSON]?, total: Int?)-> Void in
                        LOG("\(result!)")
                        self.blog.customfieldsForEntry.removeAll(keepingCapacity: false)
                        for item in result! {
                            let field = CustomField(json: item)
                            self.blog.customfieldsForEntry.append(field)
                        }
                        
                        let params = ["includeShared":"system", "systemObject":"page"]
                        api.listFields(siteID: self.blog.id, options: params, success:
                            {(result: [JSON]?, total: Int?)-> Void in
                                LOG("\(result!)")
                                self.blog.customfieldsForPage.removeAll(keepingCapacity: false)
                                for item in result! {
                                    let field = CustomField(json: item)
                                    self.blog.customfieldsForPage.append(field)
                                }

                                completion(false)
                            }
                            , failure: failure
                        )
                    }
                    , failure: failure
                )
            },
            failure: failure
        )
    }
    
    fileprivate func getPermissions(_ completion: @escaping (Bool)-> Void) {
        let api = DataAPI.sharedInstance
        let app = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
        
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            LOG("failure:\(error!.description)")
            SVProgressHUD.showError(withStatus: error!["message"].stringValue)
            completion(true)
        }
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                let params = ["fields":"permissions"]
                api.listPermissionsForSite(self.blog.id, options: params, success: {
                    (result: [JSON]?, total: Int?)-> Void in
                        LOG("\(result!)")
                        for item in result! {
                            let permissions = item["permissions"].arrayValue
                            for item in permissions {
                                let permission = item.stringValue
                                if !self.blog.hasPermission(permission) {
                                    self.blog.permissions.append(permission)
                                }
                            }
                        }
                        completion(false)
                    }
                    , failure: failure
                )
            },
            failure: failure
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        let user = (UIApplication.shared.delegate as! AppDelegate).currentUser!
        if self.blog.canListAsset(user: user) {
            return Section._Num.rawValue
        } else {
            return Section._Num.rawValue - 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case Section.blog.rawValue:
            return BlogItem._Num.rawValue
        case Section.asset.rawValue:
            return AssetItem._Num.rawValue
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) 
        
        self.adjustCellLayoutMargins(cell)

        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.textLabel?.textColor = Color.cellText
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
        
        switch indexPath.section {
        case Section.blog.rawValue:
            switch indexPath.row {
            case BlogItem.entries.rawValue:
                cell.textLabel?.text = NSLocalizedString("Entries", comment: "Entries")
                cell.imageView?.image = UIImage(named: "ico_listfolder")
            case BlogItem.draftEntries.rawValue:
                cell.textLabel?.text = NSLocalizedString("Local saved entries", comment: "Local saved entries")
                cell.imageView?.image = UIImage(named: "ico_listfolder copy")
            case BlogItem.pages.rawValue:
                cell.textLabel?.text = NSLocalizedString("Pages", comment: "Pages")
                cell.imageView?.image = UIImage(named: "ico_listfolder")
            case BlogItem.draftPages.rawValue:
                cell.textLabel?.text = NSLocalizedString("Local saved pages", comment: "Local saved pages")
                cell.imageView?.image = UIImage(named: "ico_webpage")
            default:
                cell.textLabel?.text = ""
            }
        case Section.asset.rawValue:
            switch indexPath.row {
            case AssetItem.assets.rawValue:
                cell.textLabel?.text = NSLocalizedString("Assets", comment: "Assets")
                cell.imageView?.image = UIImage(named: "ico_item")
            default:
                cell.textLabel?.text = ""
            }
        default:
            cell.textLabel?.text = ""
        }
        
        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Table view delegte
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case Section.blog.rawValue:
            return 110.0
        case Section.asset.rawValue:
            return 15.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case Section.blog.rawValue:
            let blogInfoView: BlogInfoView = BlogInfoView.instanceFromNib() as! BlogInfoView
            blogInfoView.blog = self.blog
            
            blogInfoView.BlogURLButton.addTarget(self, action: #selector(BlogTableViewController.blogURLButtonPushed(_:)), for: UIControlEvents.touchUpInside)
            blogInfoView.BlogPrefsButton.addTarget(self, action: #selector(BlogTableViewController.blogPrefsButtonPushed(_:)), for: UIControlEvents.touchUpInside)
            
            return blogInfoView
        case Section.asset.rawValue:
            return UIView()
        default:
            return UIView()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case Section.blog.rawValue:
            switch indexPath.row {
            case BlogItem.entries.rawValue:
                let vc = EntryListTableViewController()
                let blog = self.blog
                vc.blog = blog
                self.navigationController?.pushViewController(vc, animated: true)

            case BlogItem.draftEntries.rawValue:
                let vc = EntryDraftTableViewController()
                let blog = self.blog
                vc.blog = blog
                self.navigationController?.pushViewController(vc, animated: true)

            case BlogItem.pages.rawValue:
                let vc = PageListTableViewController()
                let blog = self.blog
                vc.blog = blog
                self.navigationController?.pushViewController(vc, animated: true)

            case BlogItem.draftPages.rawValue:
                let vc = PageDraftTableViewController()
                let blog = self.blog
                vc.blog = blog
                self.navigationController?.pushViewController(vc, animated: true)

            default:
                break
            }
        case Section.asset.rawValue:
            switch indexPath.row {
            case AssetItem.assets.rawValue:
                let vc = AssetListTableViewController()
                let blog = self.blog
                vc.blog = blog
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        default:
            break
        }
        
//        let storyboard: UIStoryboard = UIStoryboard(name: "Blog", bundle: nil)
//        let vc = storyboard.instantiateInitialViewController() as! BlogTableViewController
//        let blog = self.list[indexPath.row] as! Blog
//        vc.blog = blog
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    func blogURLButtonPushed(_ sender: UIButton) {
        let vc = PreviewViewController()
        let nav = UINavigationController(rootViewController: vc)
        vc.url = blog.url
        self.present(nav, animated: true, completion: nil)
    }
    
    func blogPrefsButtonPushed(_ sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "BlogSettings", bundle: nil)
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nav.topViewController as! BlogSettingsTableViewController
        vc.blog = blog
        self.present(nav, animated: true, completion: nil)
    }
    
    func composeButtonPushed(_ sender: UIBarButtonItem) {
        let actionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Create", comment: "Create"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
                LOG("cancelAction")
            }
        )
        
        let createEntryAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Create Entry", comment: "Create Entry"),
            style: UIAlertActionStyle.default,
            handler:{
                (action:UIAlertAction) -> Void in
                
                let app = UIApplication.shared.delegate as! AppDelegate
                app.createEntry(self.blog, controller: self)
            }
        )
        
        let createPageAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Create Page", comment: "Create Page"),
            style: UIAlertActionStyle.default,
            handler:{
                (action:UIAlertAction) -> Void in
                
                let app = UIApplication.shared.delegate as! AppDelegate
                app.createPage(self.blog, controller: self)
            }
        )
        
        let user = (UIApplication.shared.delegate as! AppDelegate).currentUser!
        if self.blog.canCreateEntry(user: user) {
            actionSheet.addAction(createEntryAction)
        }
        if self.blog.canCreatePage(user: user) {
            actionSheet.addAction(createPageAction)
        }
        
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}
