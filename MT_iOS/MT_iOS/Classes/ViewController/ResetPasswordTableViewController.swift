//
//  ResetPasswordTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/28.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
class ResetPasswordTableViewController: BaseTableViewController, UITextFieldDelegate {

    enum Item: Int {
        case username = 0,
        email,
        endpoint,
        spacer1,
        button,
        _Num
    }

    var username = ""
    var email = ""
    var endpoint = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationController?.isNavigationBarHidden = false
        self.title = NSLocalizedString("Forgot password", comment: "Forgot password")
        
        self.tableView.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "TextFieldTableViewCell")
        self.tableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ButtonTableViewCell")

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.backgroundColor = Color.tableBg
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return Item._Num.rawValue
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        // Configure the cell...
        switch indexPath.row {
        case Item.username.rawValue:
            let c = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            c.textField.placeholder = NSLocalizedString("username", comment: "username")
            c.textField.keyboardType = UIKeyboardType.default
            c.textField.returnKeyType = UIReturnKeyType.done
            c.textField.isSecureTextEntry = false
            c.textField.autocorrectionType = UITextAutocorrectionType.no
            c.textField.text = username
            c.textField.tag = indexPath.row
            c.textField.delegate = self
            c.textField.addTarget(self, action: #selector(ResetPasswordTableViewController.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
            c.bgImageView.image = UIImage(named: "signin_table_1")
            cell = c
            
        case Item.email.rawValue:
            let c = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            c.textField.placeholder = NSLocalizedString("email", comment: "email")
            c.textField.keyboardType = UIKeyboardType.emailAddress
            c.textField.returnKeyType = UIReturnKeyType.done
            c.textField.isSecureTextEntry = false
            c.textField.autocorrectionType = UITextAutocorrectionType.no
            c.textField.text = email
            c.textField.tag = indexPath.row
            c.textField.delegate = self
            c.textField.addTarget(self, action: #selector(ResetPasswordTableViewController.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
            c.bgImageView.image = UIImage(named: "signin_table_2")
            cell = c

        case Item.endpoint.rawValue:
            let c = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            c.textField.placeholder = NSLocalizedString("endpoint", comment: "endpoint")
            c.textField.keyboardType = UIKeyboardType.URL
            c.textField.returnKeyType = UIReturnKeyType.done
            c.textField.isSecureTextEntry = false
            c.textField.autocorrectionType = UITextAutocorrectionType.no
            c.textField.text = endpoint
            c.textField.tag = indexPath.row
            c.textField.delegate = self
            c.textField.addTarget(self, action: #selector(ResetPasswordTableViewController.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
            c.bgImageView.image = UIImage(named: "signin_table_3")
            cell = c
            
        case Item.button.rawValue:
            let c = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
            c.button.setTitle(NSLocalizedString("Reset", comment: "Reset"), for: UIControlState())
            c.button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
            c.button.setTitleColor(Color.buttonText, for: UIControlState())
            c.button.setTitleColor(Color.buttonDisableText, for: UIControlState.disabled)
            c.button.setBackgroundImage(UIImage(named: "btn_signin"), for: UIControlState())
            c.button.setBackgroundImage(UIImage(named: "btn_signin_highlight"), for: UIControlState.highlighted)
            c.button.setBackgroundImage(UIImage(named: "btn_signin_disable"), for: UIControlState.disabled)
            c.button.isEnabled = self.validate()
            c.button.addTarget(self, action: #selector(ResetPasswordTableViewController.resetButtonPushed(_:)), for: UIControlEvents.touchUpInside)
            cell = c
            
        default:
            break
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = Color.clear

        return cell
    }

    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: GroupedHeaderView = GroupedHeaderView.instanceFromNib() as! GroupedHeaderView
        headerView.label.text = NSLocalizedString("Reset password", comment: "Reset password")
        return headerView
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case Item.username.rawValue:
            return 48.0
        case Item.email.rawValue:
            return 48.0
        case Item.endpoint.rawValue:
            return 48.0
        case Item.button.rawValue:
            return 40.0
        default:
            return 12.0
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    fileprivate func validate()-> Bool {
        if username.isEmpty || email.isEmpty || endpoint.isEmpty {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func textFieldChanged(_ field: UITextField) {
        switch field.tag {
        case Item.username.rawValue:
            username = field.text!
        case Item.email.rawValue:
            email = field.text!
        case Item.endpoint.rawValue:
            endpoint = field.text!
        default:
            break
        }
        
        let cell = tableView.cellForRow(at: IndexPath(row:Item.button.rawValue , section: 0)) as! ButtonTableViewCell
        cell.button.isEnabled = self.validate()
    }

    fileprivate func resetPassword(_ username: String, email: String, endpoint: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.show(withStatus: NSLocalizedString("Reset password...", comment: "Reset password..."))
        let api = DataAPI.sharedInstance
        api.APIBaseURL = endpoint
        
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            LOG("failure:\(error!.description)")
            SVProgressHUD.showError(withStatus: error!["message"].stringValue)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        api.recoverPassword(username, email: email,
            success: {_ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                SVProgressHUD.dismiss()

                _ = self.navigationController?.popViewController(animated: true)
            },
            failure: failure
        )
    }
    
    @IBAction func resetButtonPushed(_ sender: AnyObject) {
        self.resetPassword(username, email: email, endpoint: endpoint)
    }
    
}
