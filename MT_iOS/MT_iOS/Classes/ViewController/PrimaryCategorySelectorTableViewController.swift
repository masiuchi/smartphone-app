//
//  PrimaryCategorySelectorTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/17.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

protocol PrimaryCategorySelectorDelegate {
    func primaryCategorySelectorDone(_ controller: PrimaryCategorySelectorTableViewController, selected: String)
}

class PrimaryCategorySelectorTableViewController: BaseTableViewController {
    var items = [Category]()
    var selected = ""
    var delegate: PrimaryCategorySelectorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = NSLocalizedString("Select a primary category", comment: "Select a primary category")
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        if selected.isEmpty {
            selected = items[0].id
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_close"), left: true, target: self, action: #selector(PrimaryCategorySelectorTableViewController.closeButtonPushed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(PrimaryCategorySelectorTableViewController.saveButtonPushed(_:)))
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
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 

        self.adjustCellLayoutMargins(cell)
        
        // Configure the cell...
        let item = items[indexPath.row]
        
        var path = item.path
        path = path.replacingOccurrences(of: "/", with: " > ", options: [], range: nil)
        
        cell.textLabel?.text = path
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if item.id == selected {
            cell.accessoryView = UIImageView(image: UIImage(named: "btn_primary"))
        } else {
            cell.accessoryView = nil
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        selected = item.id
        self.tableView.reloadData()
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
        self.delegate?.primaryCategorySelectorDone(self, selected: selected)
    }
    
    
    @IBAction func backButtonPushed(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
