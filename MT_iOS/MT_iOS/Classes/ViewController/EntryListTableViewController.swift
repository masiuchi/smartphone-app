//
//  EntryListTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/22.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class EntryList: ItemList {
    var blog: Blog!
    
    override func toModel(_ json: JSON)->BaseObject {
        return Entry(json: json)
    }
    
    override func fetch(_ offset: Int, success: ((_ items:[JSON]?, _ total:Int?) -> Void)!, failure: ((JSON?) -> Void)!) {
        if working {return}
        
        self.working = true
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let api = DataAPI.sharedInstance
        let app = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
        
        let success: (([JSON]?, Int?)-> Void) = {
            (result: [JSON]?, total: Int?)-> Void in
            LOG("\(result!)")
            if self.refresh {
                self.items = []
            }
            self.totalCount = total!
            self.parseItems(result!)
            success(result, total)
            self.postProcess()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            LOG("failure:\(error!.description)")
            failure(error!)
            self.postProcess()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                var params = ["limit":"10", "no_text_filter":"1"]
                params["fields"] = "id,title,status,date,author"
                if !self.refresh {
                    params["offset"] = "\(self.items.count)"
                }
                if !self.searchText.isEmpty {
                    params["search"] = self.searchText
                    params["searchFields"] = "title,body,more"
                }
                
                api.listEntries(siteID: self.blog.id, options: params, success: success, failure: failure)
            },
            failure: failure
        )
        
    }
}

class EntryListTableViewController: BaseEntryListTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Manage entries", comment: "Manage entries")

        list = EntryList()
        (list as! EntryList).blog = self.blog

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        actionMessage = NSLocalizedString("Fetch entries", comment: "Fetch entries")
        
        let user = (UIApplication.shared.delegate as! AppDelegate).currentUser!
        if self.blog.canCreateEntry(user: user) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_newentry"), left: false, target: self, action: #selector(BaseEntryListTableViewController.composeButtonPushed(_:)))
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 3
    }
    */
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Table view delegte
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.list[indexPath.row] as! Entry
        
        let app = UIApplication.shared.delegate as! AppDelegate
        if blog.canUpdateEntry(user: app.currentUser!, entry: item) {
            let vc = EntryDetailTableViewController()
            vc.object = item
            vc.blog = blog
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let alertController = UIAlertController(
                title: NSLocalizedString("Permission denied", comment: "Permission denied"),
                message: NSLocalizedString("You do not have permission.", comment: "You do not have permission."),
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .destructive) {
                action in
            }

            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }

    //MARK: -
    override func composeButtonPushed(_ sender: UIBarButtonItem) {
        let app = UIApplication.shared.delegate as! AppDelegate
        app.createEntry(self.blog, controller: self)
    }
}
