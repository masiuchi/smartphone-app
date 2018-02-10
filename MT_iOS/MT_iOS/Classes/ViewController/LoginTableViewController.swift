//
//  LoginTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/28.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class LoginTableViewController: BaseTableViewController, UITextFieldDelegate {
    enum Section: Int {
        case logo = 0,
        authInfo,
        spacer1,
        basicAuth,
        spacer2,
        loginButton,
        spacer3,
        _Num
    }
    
    enum AuthInfoItem: Int {
        case username = 0,
        password,
        endpoint,
        _Num
    }

    enum BasicAuthItem: Int {
        case button = 0,
        spacer1,
        username,
        password,
        _Num
    }
    
    enum FieldType: Int {
        case username = 1,
        password,
        endpoint,
        basicAuthUsername,
        basicAuthPassword
    }
    
    var auth = AuthInfo()
    
    var basicAuthVisibled = false
    
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationController?.isNavigationBarHidden = true
        
        self.tableView.register(UINib(nibName: "LogoTableViewCell", bundle: nil), forCellReuseIdentifier: "LogoTableViewCell")
        self.tableView.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "TextFieldTableViewCell")
        self.tableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ButtonTableViewCell")
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.backgroundColor = Color.clear
        
        let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
        if authInfo.username.isEmpty && authInfo.endpoint.isEmpty {
            authInfo.clear()
            authInfo.save()
        }
        auth.username = authInfo.username
        auth.password = authInfo.password
        auth.endpoint = authInfo.endpoint
        auth.basicAuthUsername = authInfo.basicAuthUsername
        auth.basicAuthPassword = authInfo.basicAuthPassword
        
        if !auth.basicAuthUsername.isEmpty {
            basicAuthVisibled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.insertBackGroundLayer()
    }

    private func insertBackGroundLayer() {
        gradientLayer.frame = self.view.bounds
        let startColor = Color.loginBgStart.cgColor
        let endColor = Color.loginBgEnd.cgColor
        gradientLayer.colors = [startColor, endColor]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
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
        case Section.logo.rawValue:
            return 1
        case Section.authInfo.rawValue:
            return AuthInfoItem._Num.rawValue
        case Section.basicAuth.rawValue:
            if basicAuthVisibled {
                return BasicAuthItem._Num.rawValue
            } else {
                return 1
            }
        case Section.loginButton.rawValue:
            return 1
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        
        //tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
        
        switch indexPath.section {
        case Section.logo.rawValue:
            let c = tableView.dequeueReusableCell(withIdentifier: "LogoTableViewCell", for: indexPath) as! LogoTableViewCell
            cell = c
            
        case Section.authInfo.rawValue:
            switch indexPath.row {
            case AuthInfoItem.username.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                c.textField.placeholder = NSLocalizedString("username", comment: "username")
                c.textField.keyboardType = UIKeyboardType.default
                c.textField.returnKeyType = UIReturnKeyType.done
                c.textField.isSecureTextEntry = false
                c.textField.autocorrectionType = UITextAutocorrectionType.no
                c.textField.text = auth.username
                c.textField.tag = FieldType.username.rawValue
                c.textField.delegate = self
                c.textField.addTarget(self, action: #selector(LoginTableViewController.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
                c.bgImageView.image = UIImage(named: "signin_table_1")
                cell = c
            case AuthInfoItem.password.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                c.textField.placeholder = NSLocalizedString("password", comment: "password")
                c.textField.keyboardType = UIKeyboardType.default
                c.textField.returnKeyType = UIReturnKeyType.done
                c.textField.isSecureTextEntry = true
                c.textField.autocorrectionType = UITextAutocorrectionType.no
                c.textField.text = auth.password
                c.textField.tag = FieldType.password.rawValue
                c.textField.delegate = self
                c.textField.addTarget(self, action: #selector(LoginTableViewController.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
                c.bgImageView.image = UIImage(named: "signin_table_2")
                cell = c
            case AuthInfoItem.endpoint.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                c.textField.placeholder = NSLocalizedString("endpoint", comment: "endpoint")
                c.textField.keyboardType = UIKeyboardType.URL
                c.textField.returnKeyType = UIReturnKeyType.done
                c.textField.isSecureTextEntry = false
                c.textField.autocorrectionType = UITextAutocorrectionType.no
                c.textField.text = auth.endpoint
                c.textField.tag = FieldType.endpoint.rawValue
                c.textField.delegate = self
                c.textField.addTarget(self, action: #selector(LoginTableViewController.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
                c.bgImageView.image = UIImage(named: "signin_table_3")
                cell = c
            default:
                break
            }

        case Section.basicAuth.rawValue:
            switch indexPath.row {
            case BasicAuthItem.button.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
                c.button.setTitle(NSLocalizedString("Basic Auth", comment: "Basic Auth"), for: UIControlState())
                c.button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
                c.button.setTitleColor(Color.buttonText, for: UIControlState())
                if self.basicAuthVisibled {
                    c.button.setBackgroundImage(UIImage(named: "btn_basic_open"), for: UIControlState())
                } else {
                    c.button.setBackgroundImage(UIImage(named: "btn_basic_close"), for: UIControlState())
                }
                c.button.addTarget(self, action: #selector(LoginTableViewController.basicAuthButtonPushed(_:)), for: UIControlEvents.touchUpInside)
                cell = c
            case BasicAuthItem.username.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                c.textField.placeholder = NSLocalizedString("username", comment: "username")
                c.textField.keyboardType = UIKeyboardType.default
                c.textField.returnKeyType = UIReturnKeyType.done
                c.textField.isSecureTextEntry = false
                c.textField.autocorrectionType = UITextAutocorrectionType.no
                c.textField.text = auth.basicAuthUsername
                c.textField.tag = FieldType.basicAuthUsername.rawValue
                c.textField.delegate = self
                c.textField.addTarget(self, action: #selector(LoginTableViewController.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
                c.bgImageView.image = UIImage(named: "signin_table_1")
                cell = c
            case BasicAuthItem.password.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                c.textField.placeholder = NSLocalizedString("password", comment: "password")
                c.textField.keyboardType = UIKeyboardType.default
                c.textField.returnKeyType = UIReturnKeyType.done
                c.textField.isSecureTextEntry = true
                c.textField.autocorrectionType = UITextAutocorrectionType.no
                c.textField.text = auth.basicAuthPassword
                c.textField.tag = FieldType.basicAuthPassword.rawValue
                c.textField.delegate = self
                c.textField.addTarget(self, action: #selector(LoginTableViewController.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
                c.bgImageView.image = UIImage(named: "signin_table_3")
                cell = c
            default:
                break
            }

        case Section.loginButton.rawValue:
            let c = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
            c.button.setTitle(NSLocalizedString("Sign In", comment: "Sign In"), for: UIControlState())
            c.button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
            c.button.setTitleColor(Color.buttonText, for: UIControlState())
            c.button.setTitleColor(Color.buttonDisableText, for: UIControlState.disabled)
            c.button.setBackgroundImage(UIImage(named: "btn_signin"), for: UIControlState())
            c.button.setBackgroundImage(UIImage(named: "btn_signin_highlight"), for: UIControlState.highlighted)
            c.button.setBackgroundImage(UIImage(named: "btn_signin_disable"), for: UIControlState.disabled)
            c.button.isEnabled = self.validate()
            c.button.addTarget(self, action: #selector(LoginTableViewController.signInButtonPushed(_:)), for: UIControlEvents.touchUpInside)
            cell = c

        default:
            break
        }
        
        //tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.backgroundColor = Color.clear
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        return cell
    }

    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case Section.logo.rawValue:
            return 175.0
            
        case Section.authInfo.rawValue:
            switch indexPath.row {
            case AuthInfoItem.username.rawValue:
                return 48.0
            case AuthInfoItem.password.rawValue:
                return 48.0
            case AuthInfoItem.endpoint.rawValue:
                return 48.0
            default:
                return 0.0
            }
            
        case Section.basicAuth.rawValue:
            switch indexPath.row {
            case BasicAuthItem.button.rawValue:
                return 40.0
            case BasicAuthItem.username.rawValue:
                return 48.0
            case BasicAuthItem.password.rawValue:
                return 48.0
            default:
                return 12.0
            }
            
        case Section.loginButton.rawValue:
            return 40.0
            
        case Section.spacer3.rawValue:
            return 17.0
            
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

    @IBAction func signInButtonPushed(_ sender: AnyObject) {
        let app = UIApplication.shared.delegate as! AppDelegate
        app.signIn(self.auth, showHud: true)
    }
    
    @IBAction func forgetPasswordButtonPushed(_ sender: AnyObject) {
        let vc = ResetPasswordTableViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func basicAuthButtonPushed(_ sender: AnyObject) {
        basicAuthVisibled = !basicAuthVisibled
        
        let indexPaths = [
            IndexPath(row: BasicAuthItem.spacer1.rawValue, section: Section.basicAuth.rawValue),
            IndexPath(row: BasicAuthItem.username.rawValue, section: Section.basicAuth.rawValue),
            IndexPath(row: BasicAuthItem.password.rawValue, section: Section.basicAuth.rawValue)
        ]
        self.tableView.beginUpdates()
        if basicAuthVisibled {
            self.tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.top)
        } else {
            self.tableView.deleteRows(at: indexPaths, with: UITableViewRowAnimation.top)
        }
        
        self.tableView.reloadRows(at: [IndexPath(row: BasicAuthItem.button.rawValue, section: Section.basicAuth.rawValue)], with: UITableViewRowAnimation.none)
        self.tableView.endUpdates()
    }

    fileprivate func validate()-> Bool {
        if auth.username.isEmpty || auth.password.isEmpty || auth.endpoint.isEmpty {
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
        case FieldType.username.rawValue:
            auth.username = field.text!
        case FieldType.password.rawValue:
            auth.password = field.text!
        case FieldType.endpoint.rawValue:
            auth.endpoint = field.text!
        case FieldType.basicAuthUsername.rawValue:
            auth.basicAuthUsername = field.text!
        case FieldType.basicAuthPassword.rawValue:
            auth.basicAuthPassword = field.text!
        default:
            break
        }
        
        let cell = tableView.cellForRow(at: IndexPath(row:0 , section: Section.loginButton.rawValue)) as! ButtonTableViewCell
        cell.button.isEnabled = self.validate()
    }
}
