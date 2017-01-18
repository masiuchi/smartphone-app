//
//  EntrySettingTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

protocol EntrySettingDelegate {
    func entrySettingCancel(_ controller: EntrySettingTableViewController)
    func entrySettingDone(_ controller: EntrySettingTableViewController, object: BaseEntry)
    func entrySettingDelete(_ controller: EntrySettingTableViewController, object: BaseEntry)
}

class EntrySettingTableViewController: BaseTableViewController, DatePickerViewControllerDelegate, EditorModeDelegate {
    enum Item: Int {
        case tags = 0,
        publishDate,
        unpublishDateEnabled,
        unpublishDate,
        spacer1,
        editorMode,
        spacer2,
        deleteButton,
        _Num
    }
    
    var items = [Item]()
    var object: BaseEntry!
    var blog: Blog!
    var list: EntryItemList?
    var delegate: EntrySettingDelegate?
    
    var tagObject = EntryTagItem()
    var publishDate: Date?
    var unpublishDate: Date?
    var editorMode = Entry.EditMode.richText
    
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if list!.filename.isEmpty && object.id.isEmpty {
            self.items = [
                .tags,
                .publishDate,
                .unpublishDateEnabled,
                .unpublishDate,
                .spacer1,
                .editorMode,
                .spacer2,
            ]
        } else if !object.id.isEmpty {
            self.items = [
                .tags,
                .publishDate,
                .unpublishDateEnabled,
                .unpublishDate,
                .spacer1,
                .deleteButton,
            ]

        } else {
            self.items = [
                .tags,
                .publishDate,
                .unpublishDateEnabled,
                .unpublishDate,
                .spacer1,
                .editorMode,
                .spacer2,
                .deleteButton,
            ]
        }

        
        self.title = NSLocalizedString("Advanced Setting", comment: "Advanced Setting")
        self.tableView.backgroundColor = Color.tableBg
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_close"), left: true, target: self, action: #selector(EntrySettingTableViewController.closeButtonPushed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(EntrySettingTableViewController.doneButtonPushed(_:)))
        
        let barButton:UIBarButtonItem = UIBarButtonItem(); barButton.title = "";
        self.navigationItem.backBarButtonItem = barButton;
        
        self.tableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ButtonTableViewCell")
        
        publishDate = object.date as Date?
        unpublishDate = object.unpublishedDate as Date?
        
        tagObject.id = "tag"
        tagObject.label = NSLocalizedString("Tag", comment: "Tag")
        tagObject.text = object.tagsString()
        
        self.editorMode = object.editMode
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
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
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        let separatorLineView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1.0))
        separatorLineView.backgroundColor = Color.separatorLine
        
        // Configure the cell...
        let item = items[indexPath.row]
        switch item {
        case Item.tags:
            let c = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath) 
            c.textLabel?.text = NSLocalizedString("Tags", comment: "Tags")
            c.detailTextLabel?.text = tagObject.text
            c.contentView.addSubview(separatorLineView)
            c.backgroundColor = Color.bg
            cell = c
            
        case Item.publishDate:
            let c = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath) 
            c.textLabel?.text = NSLocalizedString("Publish at", comment: "Publishat ")
            if let date = publishDate {
                c.detailTextLabel?.text = Utils.mediumDateTimeFromDate(date)
            } else {
                c.detailTextLabel?.text = ""
            }
            c.contentView.addSubview(separatorLineView)
            c.backgroundColor = Color.bg
            cell = c
            
        case Item.unpublishDateEnabled:
            let c = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath) 
            c.textLabel?.text = NSLocalizedString("Unpublish at", comment: "Unpublish at")
            c.detailTextLabel?.text = ""
            let switchCtrl = UISwitch()
            switchCtrl.isOn = (unpublishDate != nil)
            switchCtrl.addTarget(self, action: #selector(EntrySettingTableViewController.unpublishEnabledChenged(_:)), for: UIControlEvents.valueChanged)
            c.accessoryView = switchCtrl
            c.contentView.addSubview(separatorLineView)
            c.backgroundColor = Color.bg
            cell = c
            
        case Item.unpublishDate:
            let c = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath) 
            c.textLabel?.text = ""
            if let date = unpublishDate {
                c.detailTextLabel?.text = Utils.mediumDateTimeFromDate(date)
            } else {
                c.detailTextLabel?.text = NSLocalizedString("Not set", comment: "Not set")
            }
            c.contentView.addSubview(separatorLineView)
            c.backgroundColor = Color.bg
            cell = c
            
        case Item.editorMode:
            let c = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath) 
            c.textLabel?.text = NSLocalizedString("Editor Mode", comment: "Editor Mode")
            if self.editorMode == Entry.EditMode.richText {
                c.detailTextLabel?.text = Entry.EditMode.richText.label()
            } else if editorMode == Entry.EditMode.plainText {
                c.detailTextLabel?.text = Entry.EditMode.plainText.label()
            } else if editorMode == Entry.EditMode.markdown {
                c.detailTextLabel?.text = Entry.EditMode.markdown.label()
            }
            c.contentView.addSubview(separatorLineView)
            c.backgroundColor = Color.bg
            cell = c
            
        case Item.deleteButton:
            let c = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
            var titleText: String
            if object is Entry {
                if list!.filename.isEmpty {
                    titleText = NSLocalizedString("Delete this Entry", comment: "Delete this Entry")
                } else {
                    titleText = NSLocalizedString("Delete this local saved entry", comment: "Delete this local saved entry")
                }
            } else {
                if list!.filename.isEmpty {
                    titleText = NSLocalizedString("Delete this Page", comment: "Delete this Page")
                } else {
                    titleText = NSLocalizedString("Delete this local saved page", comment: "Delete this local saved page")
                }
            }
            c.button.setTitle(titleText, for: UIControlState())
            c.button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
            c.button.setTitleColor(Color.buttonText, for: UIControlState())
            c.button.setTitleColor(Color.buttonDisableText, for: UIControlState.disabled)
            c.button.setBackgroundImage(UIImage(named: "btn_signin"), for: UIControlState())
            c.button.setBackgroundImage(UIImage(named: "btn_signin_highlight"), for: UIControlState.highlighted)
            c.button.setBackgroundImage(UIImage(named: "btn_signin_disable"), for: UIControlState.disabled)
            c.button.addTarget(self, action: #selector(EntrySettingTableViewController.deleteButtonPushed(_:)), for: UIControlEvents.touchUpInside)
            c.backgroundColor = Color.clear
            
            let user = (UIApplication.shared.delegate as! AppDelegate).currentUser!
            if object is Entry {
                c.button.isEnabled = blog.canDeleteEntry(user: user, entry: object as! Entry)
            } else {
                c.button.isEnabled = blog.canDeletePage(user: user)
            }
            
            cell = c
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
        case Item.spacer1:
            cell.contentView.addSubview(separatorLineView)
            cell.backgroundColor = Color.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
        case Item.spacer2:
            cell.contentView.addSubview(separatorLineView)
            cell.backgroundColor = Color.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
        default:
            break
        }
        
        return cell
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.row]
        switch item {
        case Item.tags:
            return 48.0
        case Item.publishDate:
            return 48.0
        case Item.unpublishDateEnabled:
            return 48.0
        case Item.unpublishDate:
            return 48.0
        case Item.editorMode:
            return 48.0
        case Item.deleteButton:
            return 40.0
        case Item.spacer1:
            return 20.0
        default:
            return 12.0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndexPath = indexPath
        let item = items[indexPath.row]
        switch item {
        case Item.tags:
            let vc = EntrySingleLineTextEditorViewController()
            vc.object = tagObject
            self.navigationController?.pushViewController(vc, animated: true)
        case Item.publishDate:
            let storyboard: UIStoryboard = UIStoryboard(name: "DatePicker", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! DatePickerViewController
            if let date = publishDate {
                vc.date = date
            } else {
                vc.date = Date()
            }
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        case Item.unpublishDate:
            let storyboard: UIStoryboard = UIStoryboard(name: "DatePicker", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! DatePickerViewController
            if let date = unpublishDate {
                vc.date = date
            } else {
                vc.date = Date()
            }
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        case Item.editorMode:
            let vc = EditorModeTableViewController()
            vc.oldSelected = self.editorMode
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    @IBAction func closeButtonPushed(_ sender: AnyObject) {
        self.delegate?.entrySettingCancel(self)
    }
    
    @IBAction func doneButtonPushed(_ sender: AnyObject) {
        if let date = unpublishDate {
            if (date as NSDate).isInPast() {
                let alertController = UIAlertController(
                    title: NSLocalizedString("Error", comment: "Error"),
                    message: NSLocalizedString("'Unpublished on' dates should be dates in the future.", comment: "'Unpublished on' dates should be dates in the future."),
                    preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) {
                    action in
                }
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                
                return
            }
        }
        
        object.date = publishDate
        object.unpublishedDate = unpublishDate
        object.setTagsFromString(tagObject.text)
        object.editMode = self.editorMode
        
        self.delegate?.entrySettingDone(self, object: self.object)
    }
    
    @IBAction func deleteButtonPushed(_ sender: AnyObject) {
        var titleText: String
        var messageText: String
        if object is Entry {
            titleText = NSLocalizedString("Delete Entry", comment: "Delete Entry")
            messageText = NSLocalizedString("Are you sure you want to delete the Entry?", comment: "Are you sure you want to delete the Entry?")
        } else {
            titleText = NSLocalizedString("Delete Page", comment: "Delete Page")
            messageText = NSLocalizedString("Are you sure you want to delete the Page?", comment: "Are you sure you want to delete the Page?")
        }
        
        let alertController = UIAlertController(
            title: titleText,
            message: messageText,
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .destructive) {
            action in
            self.delegate?.entrySettingDelete(self, object: self.object)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) {
            action in
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func datePickerDone(_ controller: DatePickerViewController, date: Date) {
        if selectedIndexPath == nil {
            return
        }
        
        let item = items[selectedIndexPath!.row]
        switch item {
        case Item.publishDate:
            self.publishDate = date
        case Item.unpublishDate:
            self.unpublishDate = date
        default:
            break
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func unpublishEnabledChenged(_ sender: UISwitch) {
        if sender.isOn {
            unpublishDate = Date()
        } else {
            unpublishDate = nil
        }
        self.tableView.reloadData()
    }
    
    
    func editorModeDone(_ controller: EditorModeTableViewController, selected: Entry.EditMode) {
        self.editorMode = selected
    }
}
