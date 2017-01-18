//
//  AssetListTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/26.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class AssetList: ItemList {
    var blog: Blog!
    
    override func toModel(_ json: JSON)->BaseObject {
        return Asset(json: json)
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
                var params = ["limit":"20", "class":"image", "relatedAssets":"1"]
                if !self.refresh {
                    params["offset"] = "\(self.items.count)"
                }
                if !self.searchText.isEmpty {
                    params["search"] = self.searchText
                    params["searchFields"] = "label,filename"
                }
                
                api.listAssets(siteID: self.blog.id, options: params, success: success, failure: failure)
            },
            failure: failure
        )
        
    }
}

class AssetListTableViewController: BaseTableViewController, UISearchBarDelegate, AddAssetDelegate {
    var cameraButton: UIBarButtonItem!
    var searchBar: UISearchBar!
    
    var blog: Blog!
    var list: AssetList = AssetList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Items", comment: "Items")
        
        list.blog = self.blog

        self.refreshControl = MTRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(AssetListTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.size.width, height: 44.0)
        searchBar.barTintColor = Color.tableBg
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        searchBar.delegate = self
        
        let textField = Utils.getTextFieldFromView(searchBar)
        if textField != nil {
            textField!.enablesReturnKeyAutomatically = false
        }
        
        self.tableView.register(UINib(nibName: "AssetTableViewCell", bundle: nil), forCellReuseIdentifier: "AssetTableViewCell")
        
        self.navigationController?.toolbar.barTintColor = Color.navBar
        self.navigationController?.toolbar.tintColor = Color.navBarTint
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(AssetListTableViewController.assetDeleted(_:)), name: NSNotification.Name(rawValue: MTIAssetDeletedNotification), object: nil)
        
        cameraButton = UIBarButtonItem(image: UIImage(named: "btn_camera"), left: true, target: self, action: #selector(AssetListTableViewController.cameraButtonPushed(_:)))
        self.toolbarItems = [cameraButton]
        let user = (UIApplication.shared.delegate as! AppDelegate).currentUser!
        cameraButton.isEnabled = blog.canUpload(user: user)

    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if list.count == 0 {
            self.fetch()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
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
        SVProgressHUD.show(withStatus: NSLocalizedString("Fetch items...", comment: "Fetch items..."))
        let success: (([JSON]?, Int?)-> Void) = {
            (result: [JSON]?, total: Int?)-> Void in
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            SVProgressHUD.showError(withStatus: NSLocalizedString("Fetch items failured.", comment: "Fetch items failured."))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetTableViewCell", for: indexPath) as! AssetTableViewCell
        
        self.adjustCellLayoutMargins(cell)
        
        // Configure the cell...
        let item = self.list[indexPath.row] as! Asset
        cell.asset = item
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let asset = list[indexPath.row] as! Asset
        let storyboard: UIStoryboard = UIStoryboard(name: "AssetDetail", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! AssetDetailViewController
        vc.asset = asset
        vc.blog = blog
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    @IBAction func cameraButtonPushed(_ sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "AddAsset", bundle: nil)
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nav.topViewController as! AddAssetTableViewController
        vc.blog = blog
        vc.delegate = self
        vc.showAlign = false
        self.present(nav, animated: true, completion: nil)
    }
    
    func assetDeleted(_ note: Notification) {
        if let userInfo = note.userInfo {
            let asset = userInfo["asset"]! as! Asset
            if self.list.deleteObject(asset) {
                self.tableView.reloadData()
            }
        }
    }

    func AddAssetDone(_ controller: AddAssetTableViewController, asset: Asset) {
        self.dismiss(animated: false, completion:
            {_ in
                self.fetch()
            }
        )
    }

    func AddAssetsDone(_ controller: AddAssetTableViewController) {
        self.dismiss(animated: false, completion:
            {_ in
                self.fetch()
            }
        )
    }
    
    func AddOfflineImageDone(_ controller: AddAssetTableViewController, item: EntryImageItem) {

    }
    
    func AddOfflineImageStorageError(_ controller: AddAssetTableViewController, item: EntryImageItem) {
        
    }
}
