//
//  BaseEntryListTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/22.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class BaseEntryListTableViewController: BaseTableViewController, UISearchBarDelegate {
    var searchBar: UISearchBar!
    
    var blog: Blog!
    var list: ItemList = ItemList()
    var actionMessage = NSLocalizedString("Fetch data", comment: "Fetch data")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = MTRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(BaseEntryListTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.size.width, height: 44.0)
        searchBar.barTintColor = Color.tableBg
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        searchBar.delegate = self
        
        let textField = Utils.getTextFieldFromView(searchBar)
        if textField != nil {
            textField!.enablesReturnKeyAutomatically = false
        }
        
        self.tableView.register(UINib(nibName: "EntryTableViewCell", bundle: nil), forCellReuseIdentifier: "EntryTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Refresh
    @IBAction func refresh(_ sender:UIRefreshControl) {
        self.fetch()
    }
    
    // MARK: - fetch
    func fetch() {
        SVProgressHUD.show(withStatus: actionMessage + "...")
        let success: (([JSON]?, Int?)-> Void) = {
            (result: [JSON]?, total: Int?)-> Void in
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            SVProgressHUD.showError(withStatus: String(format: NSLocalizedString("%@ failured.", comment: "%@ failured."), arguments: [self.actionMessage]))
            self.refreshControl!.endRefreshing()
        }
        list.refresh(success, failure: failure)
    }
    
    func more() {
        let success: (([JSON]?, Int?)-> Void) = {
            (result: [JSON]?, total: Int?)-> Void in
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            self.refreshControl!.endRefreshing()
        }
        list.more(success, failure: failure)
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
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryTableViewCell", for: indexPath) as! EntryTableViewCell
    
        self.adjustCellLayoutMargins(cell)
        
        // Configure the cell...
        let item = self.list[indexPath.row] as! BaseEntry
        cell.object = item
    
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    //MARK: -
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
            
            if self.list.working {return}
            if self.list.isFinished() {return}
            
            self.more()
        }
    }
    
    //MARK: -
    func composeButtonPushed(_ sender: UIBarButtonItem) {

    }
    
    // MARK: --
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.list.searchText = searchBar.text!
        if self.list.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
        }
        self.fetch()
    }
}
