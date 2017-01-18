//
//  BaseEntryDetailTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import ZSSRichTextEditor
import SwiftyJSON
import SVProgressHUD

class stringArray {
    var items = [String]()
}

class BaseEntryDetailTableViewController: BaseTableViewController, EntrySettingDelegate, DatePickerViewControllerDelegate, AddAssetDelegate, UploaderTableViewControllerDelegate {
    var object: BaseEntry!
    var blog: Blog!
    var list: EntryItemList?
    var selectedIndexPath: IndexPath?
    var addedImageFiles = stringArray()
    
    let headerHeight: CGFloat = 30.0
    
    var uploader = MultiUploader()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = object.title
    
        self.navigationController?.toolbar.barTintColor = Color.navBar
        self.navigationController?.toolbar.tintColor = Color.navBarTint
        
        self.tableView.backgroundColor = Color.tableBg
        
        if list == nil {
            list = EntryItemList(blog: blog, object: object)
        }
        
        self.tableView.register(UINib(nibName: "EntryPermalinkTableViewCell", bundle: nil), forCellReuseIdentifier: "EntryPermalinkTableViewCell")
        self.tableView.register(UINib(nibName: "EntryTextTableViewCell", bundle: nil), forCellReuseIdentifier: "EntryTextTableViewCell")
        self.tableView.register(UINib(nibName: "EntryBasicTableViewCell", bundle: nil), forCellReuseIdentifier: "EntryBasicTableViewCell")
        self.tableView.register(UINib(nibName: "EntryBasicTableViewCell", bundle: nil), forCellReuseIdentifier: "EntryCheckboxTableViewCell")
        self.tableView.register(UINib(nibName: "EntryBasicTableViewCell", bundle: nil), forCellReuseIdentifier: "EntrySelectTableViewCell")
        self.tableView.register(UINib(nibName: "EntryBasicTableViewCell", bundle: nil), forCellReuseIdentifier: "EntryRadioTableViewCell")
        self.tableView.register(UINib(nibName: "EntryStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "EntryStatusTableViewCell")
        self.tableView.register(UINib(nibName: "EntryTextAreaTableViewCell", bundle: nil), forCellReuseIdentifier: "EntryTextAreaTableViewCell")
        self.tableView.register(UINib(nibName: "EntryImageTableViewCell", bundle: nil), forCellReuseIdentifier: "EntryImageTableViewCell")
        self.tableView.register(UINib(nibName: "EntryHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "EntryHeaderTableViewCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(BaseEntryDetailTableViewController.saveButtonPushed(_:)))
        
        if object.id.isEmpty && list!.filename.isEmpty {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_close"), left: true, target: self, action: #selector(BaseEntryDetailTableViewController.closeButtonPushed(_:)))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_arw"), left: true, target: self, action: #selector(BaseEntryDetailTableViewController.backButtonPushed(_:)))
        }
        
        self.getDetail()
    }
    
    fileprivate func makeToolbarItems() {
        var buttons = [UIBarButtonItem]()
        let settingsButtonPushed = UIBarButtonItem(image: UIImage(named: "btn_entry_setting"), left: true, target: self, action: #selector(BaseEntryDetailTableViewController.settingsButtonPushed(_:)))
        
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let previewButton = UIBarButtonItem(image: UIImage(named: "btn_preview"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BaseEntryDetailTableViewController.previewButtonPushed(_:)))
        
        let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(BaseEntryDetailTableViewController.editButtonPushed(_:)))
            
        buttons = [settingsButtonPushed, flexible, previewButton, editButton]
        
        self.setToolbarItems(buttons, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.makeToolbarItems()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func getDetail() {
        let id = self.object.id
        if id.isEmpty {
            //新規作成の時
            return
        }
        if !list!.filename.isEmpty {
            //ローカル読み出しの時
            return
        }
        
        let blogID = blog.id
        let isEntry = object is Entry
        
        let api = DataAPI.sharedInstance
        let app = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
        
        let success: ((JSON?)-> Void) = {
            (result: JSON?)-> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.dismiss()
            
            var newObject: BaseEntry
            if isEntry {
                newObject = Entry(json: result!)
            } else {
                newObject = Page(json: result!)
            }
            
            LOG("\(result!)")

            self.object = newObject
            self.list = EntryItemList(blog: self.blog, object: self.object)
            
            self.tableView.reloadData()
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.showError(withStatus: error!["message"].stringValue)
            LOG(error!.description)
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.show(withStatus: NSLocalizedString("Get detail...", comment: "Get detail..."))
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                let params = ["no_text_filter":"1"]
                if isEntry {
                    api.getEntry(siteID: blogID, entryID: id, options: params, success: success, failure: failure)
                } else {
                    api.getPage(siteID: blogID, pageID: id, options: params, success: success, failure: failure)
                }
            },
            failure: failure
        )
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if let list = self.list {
            return list.count + 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if let list = self.list {
            if section == 0 {
                return 1
            }
            
            let item = list[section - 1]
            
            if item.type == "textarea" || item.type == "image" || item.type == "embed" || item.type == "blocks"  {
                return 2
            } else {
                return 1
            }
            
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let list = self.list {
            if indexPath.section == 0 {
                if object.permalink.isEmpty {
                    return 0.0
                }
                return 44.0
            }

            let index = indexPath.section - 1
            
            if list.count < index+1 {
                return 0.0
            }

            let item = list[index]
            
            if item.type == "text" {
                return 58.0
            } else if item.type == "title" {
                return 58.0
            } else if item.type == "textarea" || item.type == "embed" || item.type == "blocks" {
                if indexPath.row == 0 {
                    return headerHeight
                } else {
                    return 90.0
                }
            } else if item.type == "checkbox" {
                return 58.0
            } else if item.type == "url" {
                return 58.0
            } else if item.type == "datetime" || item.type == "date" || item.type == "time"  {
                return 58.0
            } else if item.type == "select" {
                return 58.0
            } else if item.type == "radio" {
                return 58.0
            } else if item.type == "image" {
                if indexPath.row == 0 {
                    return headerHeight
                } else {
                    return 90.0
                }
            } else if item.type == "status" {
                return 58.0
            } else if item.type == "category" || item.type == "folder" {
                return 58.0
            }
            
            return 58.0
        }
        
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let list = self.list {
            if indexPath.section == 0 {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntryPermalinkTableViewCell", for: indexPath) as! EntryPermalinkTableViewCell
                self.adjustCellLayoutMargins(c)
                c.iconImageView.isHidden = object.permalink.isEmpty
                c.permalinkLabel.text = object.permalink
                c.backgroundColor = Color.tableBg
                
                if object.status == Entry.Status.publish.text() {
                    c.permalinkLabel.textColor = Color.linkText
                } else {
                    c.permalinkLabel.textColor = Color.placeholderText
                }

                return c
            }

            var cell = UITableViewCell()

            let index = indexPath.section - 1
            
            if list.count < index+1 {
                return cell
            }
            
            let item = list[index]
            
            if item.type == "title" {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntryTextTableViewCell", for: indexPath) as! EntryTextTableViewCell
                let text = item.dispValue()
                if text.isEmpty {
                    c.textLabel?.text = (item as! EntryTextItem).placeholder()
                    c.textLabel?.textColor = Color.placeholderText
                } else {
                    c.textLabel?.text = text
                    c.textLabel?.textColor = Color.black
                }
                cell = c
            } else if item.type == "text" {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntryBasicTableViewCell", for: indexPath) as! EntryBasicTableViewCell
                c.textLabel?.text = item.label
                c.detailTextLabel?.text = item.dispValue().isEmpty ? " " : item.dispValue()
                c.require = item.required
                cell = c

            } else if item.type == "textarea" || item.type == "embed" {
                if indexPath.row == 0 {
                    let c = tableView.dequeueReusableCell(withIdentifier: "EntryHeaderTableViewCell", for: indexPath) as! EntryHeaderTableViewCell
                    c.textLabel?.text = item.label
                    c.backgroundColor = Color.tableBg
                    c.selectionStyle = UITableViewCellSelectionStyle.none
                    c.require = item.required
                    cell = c
                } else {
                    let c = tableView.dequeueReusableCell(withIdentifier: "EntryTextAreaTableViewCell", for: indexPath) as! EntryTextAreaTableViewCell
                    let text = item.dispValue()
                    if text.isEmpty {
                        c.placeholderLabel?.text = (item as! EntryTextAreaItem).placeholder()
                        c.placeholderLabel.isHidden = false
                        c.textareaLabel.isHidden = true
                    } else {
                        c.textareaLabel?.text = Utils.removeHTMLTags(text)
                        c.placeholderLabel.isHidden = true
                        c.textareaLabel.isHidden = false
                    }
                    cell = c
                }
            } else if item.type == "blocks" {
                if indexPath.row == 0 {
                    let c = tableView.dequeueReusableCell(withIdentifier: "EntryHeaderTableViewCell", for: indexPath) as! EntryHeaderTableViewCell
                    c.textLabel?.text = item.label
                    c.backgroundColor = Color.tableBg
                    c.selectionStyle = UITableViewCellSelectionStyle.none
                    c.require = item.required
                    cell = c
                } else {
                    let blockItem = item as! EntryBlocksItem
                    if blockItem.isImageCell() {
                        let c = tableView.dequeueReusableCell(withIdentifier: "EntryImageTableViewCell", for: indexPath) as! EntryImageTableViewCell
                        LOG(blockItem.dispValue())
                        if item.dispValue().isEmpty {
                            c.assetImageView.isHidden = true
                            c.placeholderLabel?.text = blockItem.placeholder()
                            c.placeholderLabel.isHidden = false
                        } else {
                            let value = item.dispValue()
                            if !value.hasPrefix("/") {
                                c.assetImageView.sd_setImage(with: URL(string: item.dispValue()))
                            } else {
                                c.assetImageView.image = UIImage(contentsOfFile: item.dispValue())
                            }

                            c.assetImageView.isHidden = false
                            c.placeholderLabel.isHidden = true
                        }
                        cell = c
                    } else {
                        let c = tableView.dequeueReusableCell(withIdentifier: "EntryTextAreaTableViewCell", for: indexPath) as! EntryTextAreaTableViewCell
                        let text = blockItem.dispValue()
                        if text.isEmpty {
                            c.placeholderLabel?.text = blockItem.placeholder()
                            c.placeholderLabel.isHidden = false
                            c.textareaLabel.isHidden = true
                        } else {
                            c.textareaLabel?.text = Utils.removeHTMLTags(text)
                            c.placeholderLabel.isHidden = true
                            c.textareaLabel.isHidden = false
                        }
                        cell = c
                    }
                    
                }
            } else if item.type == "checkbox" {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntryCheckboxTableViewCell", for: indexPath) as! EntryBasicTableViewCell
                c.textLabel?.text = item.label
                c.detailTextLabel?.text = ""
                let switchCtrl = UISwitch()
                switchCtrl.tag = indexPath.section
                switchCtrl.isOn = (item.dispValue() == "true")
                switchCtrl.addTarget(self, action: #selector(BaseEntryDetailTableViewController.switchChanged(_:)), for: UIControlEvents.valueChanged)
                c.accessoryView = switchCtrl
                c.selectionStyle = UITableViewCellSelectionStyle.none
                c.require = item.required
                cell = c
            } else if item.type == "url" {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntryBasicTableViewCell", for: indexPath) as! EntryBasicTableViewCell
                c.textLabel?.text = item.label
                c.detailTextLabel?.text = item.dispValue().isEmpty ? " " : item.dispValue()
                c.require = item.required
                cell = c
            } else if item.type == "datetime" || item.type == "date" || item.type == "time"  {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntryBasicTableViewCell", for: indexPath) as! EntryBasicTableViewCell
                c.textLabel?.text = item.label
                c.detailTextLabel?.text = item.dispValue().isEmpty ? " " : item.dispValue()
                c.require = item.required
                cell = c
            } else if item.type == "select" {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntrySelectTableViewCell", for: indexPath) as! EntryBasicTableViewCell
                c.textLabel?.text = item.label
                c.detailTextLabel?.text = item.dispValue().isEmpty ? " " : item.dispValue()
                c.require = item.required
                cell = c
            } else if item.type == "radio" {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntryRadioTableViewCell", for: indexPath) as! EntryBasicTableViewCell
                c.textLabel?.text = item.label
                c.detailTextLabel?.text = item.dispValue().isEmpty ? " " : item.dispValue()
                c.require = item.required
                cell = c
            } else if item.type == "image" {
                if indexPath.row == 0 {
                    let c = tableView.dequeueReusableCell(withIdentifier: "EntryHeaderTableViewCell", for: indexPath) as! EntryHeaderTableViewCell
                    c.textLabel?.text = item.label
                    c.backgroundColor = Color.tableBg
                    c.selectionStyle = UITableViewCellSelectionStyle.none
                    c.require = item.required
                    cell = c
                } else {
                    let c = tableView.dequeueReusableCell(withIdentifier: "EntryImageTableViewCell", for: indexPath) as! EntryImageTableViewCell
                    if item.dispValue().isEmpty {
                        c.placeholderLabel.isHidden = false
                        c.assetImageView.isHidden = true
                        if item.descriptionText.isEmpty {
                            c.placeholderLabel.text = NSLocalizedString("Select Image...", comment: "Select Image...")
                        } else {
                            c.placeholderLabel.text = item.descriptionText
                        }
                    } else {
                        c.placeholderLabel.isHidden = true
                        c.assetImageView.isHidden = false
                        
                        if (item as! EntryImageItem).imageFilename.isEmpty {
                            c.assetImageView.sd_setImage(with: URL(string: item.dispValue()))
                        } else {
                            LOG(item.dispValue())
                            c.assetImageView.image = UIImage(contentsOfFile: item.dispValue())
                        }
                    }
                    cell = c
                }
            } else if item.type == "status" {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntrySelectTableViewCell", for: indexPath) as! EntryBasicTableViewCell
                c.textLabel?.text = item.label
                c.detailTextLabel?.text = item.dispValue().isEmpty ? " " : item.dispValue()
                c.require = item.required
                cell = c
            } else if item.type == "category" || item.type == "folder" {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntryBasicTableViewCell", for: indexPath) as! EntryBasicTableViewCell
                c.textLabel?.text = item.label
                c.detailTextLabel?.text = item.dispValue().isEmpty ? " " : item.dispValue()
                c.require = item.required
                cell = c
            } else {
                let c = tableView.dequeueReusableCell(withIdentifier: "EntryBasicTableViewCell", for: indexPath) as! EntryBasicTableViewCell
                c.textLabel?.text = item.label
                c.detailTextLabel?.text = item.dispValue().isEmpty ? " " : item.dispValue()
                c.require = item.required
                cell = c
            }
            
            self.adjustCellLayoutMargins(cell)
            
            return cell
        }

        return UITableViewCell()
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
    
    fileprivate func showTextEditor(_ object: EntryTextItem) {
        let vc = EntryTextEditorViewController()
        vc.object = object
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func showSingleLineTextEditor(_ object: EntryTextItem) {
        let vc = EntrySingleLineTextEditorViewController()
        vc.object = object
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func showRichTextEditor(_ object: EntryTextAreaItem) {
        if self.object.editMode == Entry.EditMode.plainText || !self.object.id.isEmpty {
            let vc = EntryHTMLEditorViewController()
            vc.object = object
            vc.blog = blog
            vc.entry = self.object
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = EntryRichTextViewController()
            vc.object = object
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    fileprivate func showHTMLEditor(_ object: EntryTextAreaItem) {
        let vc = EntryHTMLEditorViewController()
        vc.object = object
        vc.blog = blog
        vc.entry = self.object
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func showMarkdownEditor(_ object: EntryTextAreaItem) {
        let vc = EntryMarkdownEditorViewController()
        vc.object = object
        vc.blog = blog
        vc.entry = self.object
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func showSelector(_ object: EntrySelectItem) {
        let vc = EntrySelectTableViewController()
        vc.object = object
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func showStatusSelector(_ object: EntryStatusItem) {
        let vc = EntryStatusSelectTableViewController()
        vc.object = object
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    fileprivate func showCategorySelector(_ object: BaseEntryItem) {
        let vc = CategoryListTableViewController()
        vc.blog = blog
        vc.object = object
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func showFolderSelector(_ object: BaseEntryItem) {
        let vc = FolderListTableViewController()
        vc.blog = blog
        vc.object = object
        self.navigationController?.pushViewController(vc, animated: true)
    }

    fileprivate func showBlockEditor(_ item: EntryBlocksItem) {
        let vc = BlockEditorTableViewController()
        vc.blog = blog
        vc.blocks = item
        vc.entry = self.object
        vc.entryAddedImageFiles = self.addedImageFiles
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func showDatePicker(_ object: BaseEntryItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "DatePicker", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! DatePickerViewController

        var date: Date?
        if object is EntryDateTimeItem {
            date = (object as! EntryDateTimeItem).datetime as Date?
            vc.initialMode = .dateTime
        } else if object is EntryDateItem {
            date = (object as! EntryDateItem).date as Date?
            vc.initialMode = .date
        } else if object is EntryTimeItem {
            date = (object as! EntryTimeItem).time as Date?
            vc.initialMode = .time
        }
        
        if date == nil {
            date = Date()
        }

        vc.navTitle = object.label
        vc.date = date!
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func datePickerDone(_ controller: DatePickerViewController, date: Date) {
        if selectedIndexPath == nil {
            return
        }
        
        if let list = self.list {
            let item = list[selectedIndexPath!.section - 1]
            item.isDirty = true
            if item is EntryDateTimeItem {
                (item as! EntryDateTimeItem).datetime = date
            } else if item is EntryDateItem {
                (item as! EntryDateItem).date = date
            } else if item is EntryTimeItem {
                (item as! EntryTimeItem).time = date
            }
        }
        
        self.tableView.reloadData()
    }
    
    func switchChanged(_ sender: UISwitch) {
        if let list = self.list {
            let item = list[sender.tag - 1]
            item.isDirty = true
            if item is EntryCheckboxItem {
                (item as! EntryCheckboxItem).checked = sender.isOn
            }
        }
    }
    
    func statusChanged(_ sender: UISegmentedControl) {
        if let list = self.list {
            let item = list[sender.tag - 1]
            item.isDirty = true
            if item is EntryStatusItem {
                (item as! EntryStatusItem).selected = sender.selectedSegmentIndex
            }
        }
    }
    
    fileprivate func showAssetSelector(_ item: EntryImageItem) {
        if object.id.isEmpty {
            self.showOfflineImageSelector(item)
        } else {
            self.showImageSelector(item)
        }
    }
    
    fileprivate func showImageSelector(_ item: EntryImageItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "ImageSelector", bundle: nil)
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nav.topViewController as! ImageSelectorTableViewController
        vc.blog = blog
        vc.delegate = self
        vc.showAlign = true
        vc.object = item
        vc.entry = self.object
        self.present(nav, animated: true, completion: nil)
    }
    
    fileprivate func showOfflineImageSelector(_ item: EntryImageItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "OfflineImageSelector", bundle: nil)
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nav.topViewController as! OfflineImageSelectorTableViewController
        vc.blog = blog
        vc.delegate = self
        vc.showAlign = true
        vc.object = item
        vc.entry = self.object
        self.present(nav, animated: true, completion: nil)
    }
    
    fileprivate func imageAction(_ item: EntryImageItem) {
        if item.dispValue().isEmpty {
            self.showAssetSelector(item)
            return
        }
        
        let actionSheet: UIAlertController = UIAlertController(title:item.label,
            message: nil,
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
                LOG("cancelAction")
            }
        )
        
        let selectAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Select Image", comment: "Select Image"),
            style: UIAlertActionStyle.default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.showAssetSelector(item)
            }
        )
        
        let deleteAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete Image", comment: "Delete Image"),
            style: UIAlertActionStyle.destructive,
            handler:{
                (action:UIAlertAction) -> Void in
                item.clear()
                item.isDirty = true
                self.tableView.reloadData()
            }
        )
        
        actionSheet.addAction(selectAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndexPath = indexPath
        
        if let list = self.list {
            if indexPath.section == 0 {
                if object.status == Entry.Status.publish.text() {
                    let vc = PreviewViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    vc.url = object.permalink
                    self.present(nav, animated: true, completion: nil)
                }
                return
            }
            
            let item = list[indexPath.section - 1]

            if item.type == "title" {
                self.showSingleLineTextEditor(item as! EntryTextItem)
            } else if item.type == "text" {
                self.showSingleLineTextEditor(item as! EntryTextItem)
            } else if item.type == "textarea" || item.type == "embed"  {
                if indexPath.row == 0 {
                    // Do nothing
                    return
                } else {
                    if item.id == "body" || item.id == "more" {
                        if self.object.format.hasPrefix(Entry.EditMode.markdown.format()) {
                            self.showMarkdownEditor(item as! EntryTextAreaItem)
                        } else {
                            self.showRichTextEditor(item as! EntryTextAreaItem)
                        }
                    } else {
                        self.showHTMLEditor(item as! EntryTextAreaItem)
                    }
                }
            } else if item.type == "blocks" {
                self.showBlockEditor(item as! EntryBlocksItem)
            } else if item.type == "checkbox" {
                // Do nothing
            } else if item.type == "url" {
                self.showSingleLineTextEditor(item as! EntryURLItem)
            } else if item.type == "datetime" || item.type == "date" || item.type == "time" {
                self.showDatePicker(item)
            } else if item.type == "select" {
                self.showSelector(item as! EntrySelectItem)
            } else if item.type == "radio" {
                self.showSelector(item as! EntryRadioItem)
            } else if item.type == "image" {
                self.imageAction(item as! EntryImageItem)
            } else if item.type == "status" {
                self.showStatusSelector(item as! EntryStatusItem)
            } else if item.type == "category" {
                self.showCategorySelector(item as! EntryCategoryItem)
            } else if item.type == "folder" {
                self.showFolderSelector(item as! PageFolderItem)
            } else {
            }
        }
    }
    
    @IBAction func settingsButtonPushed(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "EntrySetting", bundle: nil)
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nav.topViewController as! EntrySettingTableViewController
        vc.object = object
        vc.blog = blog
        vc.list = list
        vc.delegate = self
        self.present(nav, animated: true, completion: nil)
    }

    fileprivate func previewSuccess(_ controller: UploaderTableViewController) {
        controller.dismiss(animated: false,
            completion: {
                guard let json = controller.result else {
                    return
                }
                
                var url = ""
                if json["preview"].exists() {
                    url = json["preview"].stringValue
                }
                
                if !url.isEmpty {
                    let vc = PreviewViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    vc.url = url
                    self.present(nav, animated: true, completion: nil)
                }
            }
        )
    }
    
    func UploaderFinish(_ controller: UploaderTableViewController) {
        if controller.mode == .preview {
            self.previewSuccess(controller)
        } else if controller.mode == .postEntry || controller.mode == .postPage {
            self.postSuccess(controller)
        }
    }
    
    fileprivate func preview() {
        self.uploader = MultiUploader()
        uploader.blogID = self.blog.id
        if let items = self.list?.notUploadedImages() {
            for item in items {
                uploader.addImageItem(imageItem: item, blogID: self.blog.id)
            }
        }
        
        uploader.addPreview(itemList: self.list!)
        
        let vc = UploaderTableViewController()
        vc.mode = .preview
        vc.uploader = uploader
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: false, completion: nil)
    }

/*
    private func preview() {
        let json = self.makeParams(true)
        if json == nil {
            return
        }
        
        let isEntry = object is Entry
        let blogID = blog.id
        let id: String? = object.id.isEmpty ? nil : object.id
        
        let api = DataAPI.sharedInstance
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let authInfo = app.authInfo
        
        let success: (JSON!-> Void) = {
            (result: JSON!)-> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            SVProgressHUD.dismiss()
            
            let url = result["preview"].stringValue
            
            let vc = PreviewViewController()
            let nav = UINavigationController(rootViewController: vc)
            vc.url = url
            self.presentViewController(nav, animated: true, completion: nil)
        }
        let failure: (JSON!-> Void) = {
            (error: JSON!)-> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            SVProgressHUD.showErrorWithStatus(error["message"].stringValue)
            LOG(error.description)
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        SVProgressHUD.showWithStatus(NSLocalizedString("Make preview...", comment: "Make preview..."))
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                if isEntry {
                    api.previewEntry(siteID: blogID, entryID: id, entry: json, success: success, failure: failure)
                } else {
                    api.previewPage(siteID: blogID, pageID: id, entry: json, success: success, failure: failure)
                }
            },
            failure: failure
        )
    }
*/
    
    @IBAction func previewButtonPushed(_ sender: UIBarButtonItem) {
        if !Utils.hasConnectivity() {
            SVProgressHUD.showError(withStatus: NSLocalizedString("You can not connect to the network.", comment: "You can not connect to the network."))
            return
        }

        if let items = self.list?.notUploadedImages() {
            if items.count == 0 {
                self.preview()
                return
            }
            
            let alertController = UIAlertController(
                title: NSLocalizedString("Preview", comment: "Preview"),
                message: NSLocalizedString("Need to upload the images to make a preview.\nAre you sure you want to continue a preview?", comment: "Need to upload the images to make a preview.\nAre you sure you want to continue a preview?"),
                preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: NSLocalizedString("YES", comment: "YES"), style: .default) {
                action in
                
                self.preview()
            }
            let noAction = UIAlertAction(title: NSLocalizedString("NO", comment: "NO"), style: .default) {
                action in
                
            }
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.preview()
        }
    }
    
    @IBAction func editButtonPushed(_ sender: UIBarButtonItem) {
        let vc = EntryItemListTableViewController()
        let nav = UINavigationController(rootViewController: vc)
        vc.list = list
        self.present(nav, animated: true, completion: nil)
    }
    
    fileprivate func makeParams(_ preview: Bool)-> [String:AnyObject]? {
        if let params = list?.makeParams(preview) {
            return params
        }

        return nil
    }
    
    fileprivate func postSuccess(_ controller: UploaderTableViewController) {
        controller.dismiss(animated: false,
            completion: {
                guard let json = controller.result else {
                    return
                }

                let isEntry = self.object is Entry
                
                _ = self.list!.removeDraftData()
                
                var newObject: BaseEntry? = nil
                if isEntry {
                    newObject = Entry(json: json)
                } else {
                    newObject = Page(json: json)
                }
                
                if newObject != nil {
                    self.object = newObject
                }
                
                self.title = self.object.title
                
                self.list = EntryItemList(blog: self.blog, object: self.object)
                
                self.tableView.reloadData()
                self.makeToolbarItems()
                
                self.list!.clean()
            }
        )
    }

    fileprivate func saveEntry() {
        self.uploader = MultiUploader()
        uploader.blogID = self.blog.id
        if let items = self.list?.notUploadedImages() {
            for item in items {
                uploader.addImageItem(imageItem: item, blogID: self.blog.id)
            }
        }
        
        uploader.addPost(itemList: self.list!)
        
        let vc = UploaderTableViewController()
        vc.mode = object is Entry ? .postEntry : .postPage
        vc.uploader = uploader
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: false, completion: nil)
    }
    
/*
    private func saveEntry() {
        let json = self.makeParams(false)
        if json == nil {
            return
        }
        
        let create = object.id.isEmpty
        let isEntry = object is Entry
        
        let blogID = blog.id
        let id = object.id
        
        let api = DataAPI.sharedInstance
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let authInfo = app.authInfo
        
        let success: (JSON!-> Void) = {
            (result: JSON!)-> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            SVProgressHUD.dismiss()
            
            self.list!.removeDraftData()
            
            var newObject: BaseEntry
            if isEntry {
                newObject = Entry(json: result)
            } else {
                newObject = Page(json: result)
            }

            self.object = newObject
            
            self.title = self.object.title
            
            self.list = EntryItemList(blog: self.blog, object: self.object)
            
            self.tableView.reloadData()
            self.makeToolbarItems()
            
            SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Success", comment: "Success"))
            self.list!.clean()
        }
        let failure: (JSON!-> Void) = {
            (error: JSON!)-> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            SVProgressHUD.showErrorWithStatus(error["message"].stringValue)
            LOG(error.description)
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        SVProgressHUD.showWithStatus(NSLocalizedString("Save...", comment: "Save..."))

        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                let params = ["no_text_filter":"1"]
                if create {
                    if isEntry {
                        api.createEntry(siteID: blogID, entry: json!, options: params, success: success, failure: failure)
                    } else {
                        api.createPage(siteID: blogID, page: json!, options: params, success: success, failure: failure)
                    }
                } else {
                    if isEntry {
                        api.updateEntry(siteID: blogID, entryID: id, entry: json!, options: params, success: success, failure: failure)
                    } else {
                        api.updatePage(siteID: blogID, pageID: id, page: json!, options: params, success: success, failure: failure)
                    }
                }
            },
            failure: failure
        )
    }
*/
    fileprivate func checkModified() {
        let id = self.object.id
        if id.isEmpty {
            self.saveEntry()
        }

        let blogID = blog.id
        let isEntry = object is Entry

        let api = DataAPI.sharedInstance
        let app = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
        
        let success: ((JSON?)-> Void) = {
            (result: JSON?)-> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.dismiss()
            
            LOG(result!.description)
            
            var newObject: BaseEntry
            if isEntry {
                newObject = Entry(json: result!)
            } else {
                newObject = Page(json: result!)
            }
            
            if newObject.modifiedDate?.compare(self.object.modifiedDate! as Date) != .orderedSame {
                let alertController = UIAlertController(
                    title: NSLocalizedString("Caution", comment: "Caution"),
                    message: NSLocalizedString("Data on the server seems to be new . Do you want to overwrite it ?", comment: "Data on the server seems to be new . Do you want to overwrite it ?"),
                    preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .destructive) {
                    action in
                    self.saveEntry()
                }
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) {
                    action in
                }
                
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.saveEntry()
            }
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.showError(withStatus: error!["message"].stringValue)
            LOG(error!.description)
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.show(withStatus: NSLocalizedString("Check modified at...", comment: "Check modified at..."))
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                let params = ["fields":"id,modifiedDate"]
                if isEntry {
                    api.getEntry(siteID: blogID, entryID: id, options: params, success: success, failure: failure)
                } else {
                    api.getPage(siteID: blogID, pageID: id, options: params, success: success, failure: failure)
                }
            },
            failure: failure
        )

    }
    
    fileprivate func saveLocal() {
        if let titleItem = self.list!.itemWithID("title", isCustomField: false) {
            self.object.title = titleItem.value()
            self.title = titleItem.value()
        }
        if let statusItem = self.list!.itemWithID("status", isCustomField: false) {
            self.object.status = statusItem.value()
        }
        let success = self.list!.saveToFile()
        if !success {
            SVProgressHUD.showError(withStatus: NSLocalizedString("Save failed", comment: "Save failed"))
        } else {
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Success", comment: "Success"))
            self.list!.clean()
        }
    }
    
    @IBAction func saveButtonPushed(_ sender: UIBarButtonItem) {
        if let item = list!.requiredCheck() {
            let message = String(format: NSLocalizedString("Please enter some value for required '%@' field.", comment: "Please enter some value for required '%@' field."), arguments: [item.label])
            let alertController = UIAlertController(
                title: NSLocalizedString("Error", comment: "Error"),
                message: message,
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) {
                action in
            }
            
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        let actionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Submit", comment: "Submit"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
                LOG("cancelAction")
            }
        )
        
        let submitAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Submit", comment: "Submit"),
            style: UIAlertActionStyle.default,
            handler:{
                (action:UIAlertAction) -> Void in
                
                if !self.object.id.isEmpty && !self.list!.filename.isEmpty {
                    self.checkModified()
                } else {
                    self.saveEntry()
                }
            }
        )
        
        let saveLocalAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Save Local", comment: "Save Local"),
            style: UIAlertActionStyle.default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.saveLocal()
            }
        )
        
        actionSheet.addAction(submitAction)
        actionSheet.addAction(saveLocalAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func entrySettingCancel(_ controller: EntrySettingTableViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func entrySettingDone(_ controller: EntrySettingTableViewController, object: BaseEntry) {
        if let list = self.list {
            for item in list.items {
                if item is EntryBlocksItem {
                    (item as! EntryBlocksItem).editMode = object.editMode
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func deleteEntry(_ object: BaseEntry) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if object is Entry {
            SVProgressHUD.show(withStatus: NSLocalizedString("Delete Entry...", comment: "Delete Entry..."))
        } else {
            SVProgressHUD.show(withStatus: NSLocalizedString("Delete Page...", comment: "Delete Page..."))
        }
        let api = DataAPI.sharedInstance
        let app = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
        
        let success: ((JSON?)-> Void) = {
            (result: JSON?)-> Void in
            LOG("\(result!)")
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.dismiss()
            
            if self.presentingViewController != nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            LOG("failure:\(error!.description)")
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.showError(withStatus: error!["message"].stringValue)
        }
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                if object is Entry {
                    api.deleteEntry(siteID: self.blog.id, entryID: object.id, success: success, failure: failure)
                } else {
                    api.deletePage(siteID: self.blog.id, pageID: object.id, success: success, failure: failure)
                }
            },
            failure: failure
        )
    }
    
    fileprivate func deleteDraft() {
        _ = self.list!.removeDraftData()
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func entrySettingDelete(_ controller: EntrySettingTableViewController, object: BaseEntry) {
        self.dismiss(animated: false, completion:
            {_ in
                if self.list!.filename.isEmpty {
                    self.deleteEntry(object)
                } else {
                    self.deleteDraft()
                }
            }
        )
    }
    
    func AddAssetDone(_ controller: AddAssetTableViewController, asset: Asset) {
        self.dismiss(animated: false, completion: {
            let vc = controller as! ImageSelectorTableViewController
            let item = vc.object
            item?.asset = asset
            item?.isDirty = true
            self.tableView.reloadData()
        })
    }
    
    func AddAssetsDone(_ controller: AddAssetTableViewController) {
    }
    
    func AddOfflineImageDone(_ controller: AddAssetTableViewController, item: EntryImageItem) {
        self.dismiss(animated: false, completion: {
            item.asset = nil
            item.isDirty = true
            self.addedImageFiles.items.append(item.imageFilename)
            self.tableView.reloadData()
        })
    }
    
    func AddOfflineImageStorageError(_ controller: AddAssetTableViewController, item: EntryImageItem) {
        self.dismiss(animated: false, completion: {
            let alertController = UIAlertController(
                title: NSLocalizedString("Error", comment: "Error"),
                message: NSLocalizedString("The selected image could not be saved to the storage.", comment: "The selected image could not be saved to the storage."),
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) {
                action in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }

    func cleanup() {
        for path in self.addedImageFiles.items {
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
            }
        }
    }
    
    @IBAction func closeButtonPushed(_ sender: AnyObject) {
        for item in self.list!.items {
            if item.isDirty {
                Utils.confrimSave(self, dismiss: true, block: {self.cleanup()})
                return
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonPushed(_ sender: UIBarButtonItem) {
        for item in self.list!.items {
            if item.isDirty {
                Utils.confrimSave(self, block: {self.cleanup()})
                return
            }
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
}
