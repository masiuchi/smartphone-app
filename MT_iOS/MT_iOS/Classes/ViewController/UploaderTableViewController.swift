//
//  UploaderTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2016/02/09.
//  Copyright © 2016年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

protocol UploaderTableViewControllerDelegate {
    func UploaderFinish(_ controller: UploaderTableViewController)
}

class UploaderTableViewController: BaseTableViewController {
    var uploader: MultiUploader!
    var delegate: UploaderTableViewControllerDelegate?

    var progress: ((UploadItem, Float)-> Void)!
    var success: ((Int)-> Void)!
    var failure: ((Int, JSON) -> Void)!
    
    enum Mode {
        case images,
        preview,
        postEntry,
        postPage
        func title()->String {
            switch(self) {
            case .images:
                return NSLocalizedString("Upload images...", comment: "Upload images...")
            case .preview:
                return NSLocalizedString("Make preview...", comment: "Make preview...")
            case .postEntry:
                return NSLocalizedString("Sending entry...", comment: "Sending entry...")
            case .postPage:
                return NSLocalizedString("Sending page...", comment: "Sending page...")
            }
        }
    }
    
    var mode = Mode.images
    
    fileprivate(set) var result: JSON?
    
    let IMAGE_SIZE: CGFloat = 50.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = self.mode.title()
        
        self.tableView.register(UINib(nibName: "UploaderTableViewCell", bundle: nil), forCellReuseIdentifier: "UploaderTableViewCell")
        
        self.progress = {
            (item: UploadItem, progress: Float) in
            self.tableView.reloadData()
        }
        self.success = {
            (processed: Int) in
            
            self.result = self.uploader.result
            self.delegate?.UploaderFinish(self)
        }
        self.failure = {
            (processed: Int, error: JSON) in
            
            self.uploadError(error)
            self.tableView.reloadData()
        }

        self.uploader.start(progress: self.progress, success: self.success, failure: self.failure)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return uploader.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UploaderTableViewCell", for: indexPath) as! UploaderTableViewCell

        // Configure the cell...
        let item = self.uploader.items[indexPath.row]
        cell.uploaded = item.uploaded
        cell.progress = item.progress
        cell.nameLabel.text = item.filename
        item.thumbnail(CGSize(width: IMAGE_SIZE, height: IMAGE_SIZE),
            completion: { image in
                cell.thumbView.image = image
            }
        )
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return IMAGE_SIZE
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func uploadRestart() {
        let alertController = UIAlertController(
            title: NSLocalizedString("Upload", comment: "Upload"),
            message: NSLocalizedString("There is the rest of the items. Are you sure you want to upload again?", comment: "There is the rest of the items. Are you sure you want to upload again?"),
            preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: NSLocalizedString("YES", comment: "YES"), style: .default) {
            action in
            
            self.uploader.restart(progress: self.progress, success: self.success, failure: self.failure)
        }
        let noAction = UIAlertAction(title: NSLocalizedString("NO", comment: "NO"), style: .default) {
            action in
            self.delegate?.UploaderFinish(self)
        }
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func uploadError(_ error: JSON) {
        let alertController = UIAlertController(
            title: NSLocalizedString("Upload error", comment: "Upload error"),
            message: error["message"].stringValue,
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) {
            action in
            if self.uploader.queueCount() > 0 {
                self.uploadRestart()
            }
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
