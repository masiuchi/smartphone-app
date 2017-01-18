//
//  BlogUploadDirTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/10.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

protocol BlogUploadDirDelegate {
    func blogUploadDirDone(_ controller: BlogUploadDirTableViewController, directory: String)
}


class BlogUploadDirTableViewController: BaseTableViewController {

    var directory = ""
    var delegate: BlogUploadDirDelegate?
    var field: UITextField?
    var editable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = NSLocalizedString("Upload Dir", comment: "Upload Dir")
        self.tableView.backgroundColor = Color.tableBg
        
        if directory.hasPrefix("/") {
            directory = (directory as NSString).substring(from: 1)
        }
        
        if self.editable {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(BlogUploadDirTableViewController.doneButtonPushed(_:)))
        }
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
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) 

        self.adjustCellLayoutMargins(cell)
        
        // Configure the cell...
        field = cell.viewWithTag(99) as? UITextField
        field?.keyboardType = UIKeyboardType.URL
        field?.autocorrectionType = UITextAutocorrectionType.no
        field?.text = directory
        field?.isEnabled = self.editable
        field?.becomeFirstResponder()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.size.width, height: self.tableView(tableView, heightForHeaderInSection: 0)))
        let label = UILabel(frame: CGRect(x: 10.0, y: 0.0, width: header.frame.size.width - 10.0 * 2, height: header.frame.size.height))
        label.text = NSLocalizedString("Upload Directory", comment: "Upload Directory")
        label.textColor = Color.placeholderText
        label.font = UIFont.systemFont(ofSize: 15.0)
        header.addSubview(label)
        
        return header
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
    
    @IBAction func doneButtonPushed(_ sender: AnyObject) {
        if field != nil {
            var dir = field!.text
            if Utils.validatePath(dir!) {
                if !dir!.hasPrefix("/") {
                    dir = "/" + dir!
                }
                delegate?.blogUploadDirDone(self, directory: dir!)
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                let alertController = UIAlertController(
                    title: NSLocalizedString("Error", comment: "Error"),
                    message: NSLocalizedString("You must set a valid path.", comment: "You must set a valid path."),
                    preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) {
                    action in
                }
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }

}
