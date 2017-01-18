//
//  BlogSettingsTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/26.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class BlogSettingsTableViewController: BaseTableViewController, BlogImageSizeDelegate, BlogImageQualityDelegate, BlogUploadDirDelegate, EditorModeDelegate {
    enum Item:Int {
        case uploadDir = 0,
        size,
        quality,
        editor,
        _Num
    }
    
    var blog: Blog!
    
    var uploadDir = "/"
    var imageSize = Blog.ImageSize.m
    var imageQuality = Blog.ImageQuality.normal
    var imageCustomWidth = 0
    var editorMode = Entry.EditMode.richText

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = NSLocalizedString("Settings", comment: "Settings")
        
        self.tableView.backgroundColor = Color.tableBg
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_close"), left: true, target: self, action: #selector(BlogSettingsTableViewController.closeButtonPushed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(BlogSettingsTableViewController.saveButtonPushed(_:)))

        uploadDir = blog.uploadDir
        imageSize = blog.imageSize
        imageQuality = blog.imageQuality
        imageCustomWidth = blog.imageCustomWidth
        editorMode = blog.editorMode
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) 
        
        self.adjustCellLayoutMargins(cell)
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.textLabel?.textColor = Color.cellText
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
        cell.detailTextLabel?.textColor = Color.black
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)
        
        switch indexPath.row {
        case Item.uploadDir.rawValue:
            cell.textLabel?.text = NSLocalizedString("Upload Dir", comment: "Upload Dir")
            cell.imageView?.image = UIImage(named: "ico_upload")
            cell.detailTextLabel?.text = uploadDir
            
            cell.textLabel?.textColor = Color.cellText
            cell.detailTextLabel?.textColor = Color.black
            cell.imageView?.alpha = 1.0
        case Item.size.rawValue:
            cell.textLabel?.text = NSLocalizedString("Image Size", comment: "Image Size")
            cell.imageView?.image = UIImage(named: "ico_size")
            if self.imageSize == Blog.ImageSize.custom {
                cell.detailTextLabel?.text = imageSize.label() + "(\(imageCustomWidth)px)"
            } else {
                cell.detailTextLabel?.text = imageSize.label() + "(" + imageSize.pix() + ")"
            }
        case Item.quality.rawValue:
            cell.textLabel?.text = NSLocalizedString("Image Quality", comment: "Image Quality")
            cell.imageView?.image = UIImage(named: "ico_quality")
            cell.detailTextLabel?.text = imageQuality.label()
        case Item.editor.rawValue:
            cell.textLabel?.text = NSLocalizedString("Editor Mode", comment: "Editor Mode")
            if editorMode == Entry.EditMode.richText {
                cell.detailTextLabel?.text = Entry.EditMode.richText.label()
            } else if editorMode == Entry.EditMode.plainText {
                cell.detailTextLabel?.text = Entry.EditMode.plainText.label()
            } else if editorMode == Entry.EditMode.markdown {
                cell.detailTextLabel?.text = Entry.EditMode.markdown.label()
            }
            cell.imageView?.image = UIImage(named: "ico_editor")
        default:
            cell.textLabel?.text = ""
        }
        
        // Configure the cell...
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 21.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58.0
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
        switch indexPath.row {
        case Item.uploadDir.rawValue:
            let storyboard: UIStoryboard = UIStoryboard(name: "BlogUploadDir", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! BlogUploadDirTableViewController
            vc.directory = uploadDir
            vc.delegate = self
            //vc.editable = self.blog.allowToChangeAtUpload
            vc.editable = true
            self.navigationController?.pushViewController(vc, animated: true)
        case Item.size.rawValue:
            let storyboard: UIStoryboard = UIStoryboard(name: "BlogImageSize", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! BlogImageSizeTableViewController
            vc.selected = imageSize.rawValue
            vc.customWidth = imageCustomWidth
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        case Item.quality.rawValue:
            let storyboard: UIStoryboard = UIStoryboard(name: "BlogImageQuality", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! BlogImageQualityTableViewController
            vc.selected = imageQuality.rawValue
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        case Item.editor.rawValue:
            let vc = EditorModeTableViewController()
            vc.oldSelected = self.editorMode
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
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

    @IBAction func closeButtonPushed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPushed(_ sender: AnyObject) {
        blog.uploadDir = uploadDir
        blog.imageSize = imageSize
        blog.imageQuality = imageQuality
        blog.imageCustomWidth = imageCustomWidth
        blog.editorMode = editorMode
        blog.saveSettings()
        self.dismiss(animated: true, completion: nil)
    }
    
    func blogImageSizeDone(_ controller: BlogImageSizeTableViewController, selected: Int, customWidth: Int) {
        imageSize = Blog.ImageSize(rawValue: selected)!
        imageCustomWidth = customWidth
        self.tableView.reloadData()
    }
    
    func blogImageQualityDone(_ controller: BlogImageQualityTableViewController, selected: Int) {
        imageQuality = Blog.ImageQuality(rawValue: selected)!
        self.tableView.reloadData()
    }
    
    func blogUploadDirDone(_ controller: BlogUploadDirTableViewController, directory: String) {
        uploadDir = directory
        self.tableView.reloadData()
    }

    func editorModeDone(_ controller: EditorModeTableViewController, selected: Entry.EditMode) {
        self.editorMode = selected
        self.tableView.reloadData()
    }
}
