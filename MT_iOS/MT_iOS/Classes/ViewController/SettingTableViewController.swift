//
//  SettingTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/19.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class SettingTableViewController: BaseTableViewController {
    enum Section: Int {
        case item = 0,
        logout,
        _Num
    }
    
    enum Item: Int {
        case help = 0,
        license,
        reportBug,
        _Num
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = NSLocalizedString("Setting", comment: "Setting")
        self.tableView.backgroundColor = Color.tableBg

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_close"), left: true, target: self, action: #selector(SettingTableViewController.closeButtonPushed(_:)))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return Section._Num.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case Section.item.rawValue:
            return Item._Num.rawValue
        case Section.logout.rawValue:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        switch indexPath.section {
        case Section.item.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) 

            self.adjustCellLayoutMargins(cell)

            switch indexPath.row {
            case Item.help.rawValue:
                cell.textLabel?.text = NSLocalizedString("Help", comment: "Help")
            case Item.license.rawValue:
                cell.textLabel?.text = NSLocalizedString("License", comment: "License")
            case Item.reportBug.rawValue:
                cell.textLabel?.text = NSLocalizedString("Report bug", comment: "Report bug")
            default:
                break
            }
        case Section.logout.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath) 
            cell.textLabel?.text = NSLocalizedString("Logout", comment: "Logout")
        default:
            break
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case Section.item.rawValue:
            return 58.0
        case Section.logout.rawValue:
            return 58.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == Section.logout.rawValue {
            return 50.0
        }
        
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == Section.logout.rawValue {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14.0)
            label.textColor = Color.placeholderText
            label.textAlignment = NSTextAlignment.center
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                label.text = NSLocalizedString("Movable Type for iOS ver. ", comment: "Movable Type for iOS ver. ") +  version
            }
            return label
        }
        
        return nil
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lang = Utils.preferredLanguage()
        let isJP = (lang as NSString).substring(to: 2) == "ja" ? true : false
        switch indexPath.section {
        case Section.item.rawValue:
            switch indexPath.row {
            case Item.help.rawValue:
                let vc = CommonWebViewController()
                vc.urlString = HELP_URL
                if !isJP {
                    vc.urlString += "en"
                }
                self.navigationController?.pushViewController(vc, animated: true)
            case Item.license.rawValue:
                let vc = CommonWebViewController()
                let path = Bundle.main.path(forResource: "license", ofType: "html")
                vc.filePath = path!
                self.navigationController?.pushViewController(vc, animated: true)
            case Item.reportBug.rawValue:
                let vc = CommonWebViewController()
                vc.urlString = REPORT_BUG_URL
                if !isJP {
                    vc.urlString += "/en"
                }
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        case Section.logout.rawValue:
            let app = UIApplication.shared.delegate as! AppDelegate
            app.logout()
        default:
            break
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: -
    func closeButtonPushed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
