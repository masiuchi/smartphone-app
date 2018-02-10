//
//  BlogListTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/19.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class BlogList: ItemList {
    override func toModel(_ json: JSON)->BaseObject {
        return Blog(json: json)
    }
    
    override func fetch(_ offset: Int, success: ((_ items:[JSON]?, _ total:Int?) -> Void)!, failure: ((JSON?) -> Void)!) {
        if working {return}
        
        self.working = true

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let api = DataAPI.sharedInstance
        let app = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
    
        let success: (([JSON]?, Int?)-> Void) = {
            (result: [JSON]?, total: Int?)-> Void in
            LOG("\(result!)")
            if self.refresh {
                self.items = []
            }
            self.totalCount = total!
            self.parseItems(result!)
            for item in self.items as! [Blog] {
                item.endpoint = authInfo.endpoint
                item.loadSettings()
                item.adjustUploadDestination()
            }
            success(result, total)
            self.postProcess()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            LOG("failure:\(error!.description)")
            failure(error!)
            self.postProcess()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                var params = ["limit":"20"]
                params["fields"] = "id,name,url,parent,allowToChangeAtUpload,uploadDestination"

                if !self.refresh {
                    params["offset"] = "\(self.items.count)"
                }
                if !self.searchText.isEmpty {
                    params["search"] = self.searchText
                    params["searchFields"] = "name"
                }
                api.listBlogsForUser("me", options: params, success: success, failure: failure)
            },
            failure: failure
        )

    }
}

//MARK: -

class BlogListTableViewController: BaseTableViewController, UISearchBarDelegate {
    var list: BlogList = BlogList()
    var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("System", comment: "System")
        
        searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.size.width, height: 44.0)
        searchBar.barTintColor = Color.tableBg
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        searchBar.delegate = self
        
        let textField = Utils.getTextFieldFromView(searchBar)
        if textField != nil {
            textField!.enablesReturnKeyAutomatically = false
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_setting"), left: true, target: self, action: #selector(BlogListTableViewController.settingButtonPushed(_:)))
            
//        self.tableView.estimatedRowHeight = 44.0
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.fetch()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Refresh
    @IBAction func refresh(_ sender:UIRefreshControl) {
        self.fetch()
    }
    
    // MARK: - fetch
    func fetch() {
        SVProgressHUD.show(withStatus: NSLocalizedString("Fetch sites...", comment: "Fetch sites..."))
        let success: (([JSON]?, Int?)-> Void) = {
            (result: [JSON]?, total: Int?)-> Void in
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            SVProgressHUD.showError(withStatus: NSLocalizedString("Fetch sites failured.", comment: "Fetch sites failured."))
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
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) 
    
        self.adjustCellLayoutMargins(cell)
        
        // Configure the cell...
        cell.textLabel?.textColor = Color.cellText
        cell.textLabel?.font = UIFont.systemFont(ofSize: 21.0)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)
        
        
        let blog = self.list[indexPath.row] as! Blog
        cell.textLabel?.text = blog.name
        cell.detailTextLabel?.text = blog.parentName
    
        return cell
    }
    
    // MARK: - Table view delegte
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Blog", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! BlogTableViewController
        let blog = self.list[indexPath.row] as! Blog
        vc.blog = blog
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0
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
    func settingButtonPushed(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Setting", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        self.present(vc!, animated: true, completion: nil)
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
