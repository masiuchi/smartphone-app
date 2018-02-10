//
//  AssetDetailViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/29.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class AssetDetailViewController: BaseViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var CreatedAtLabel: UILabel!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var asset: Asset!
    var blog: Blog!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = asset.dispName()
        self.imageView.sd_setImage(with: URL(string: asset.url))
        
        self.sizeLabel.text = NSLocalizedString("Size：", comment: "Size：") + "\(asset.width) x \(asset.height)"
        self.AuthorLabel.text = NSLocalizedString("Author：", comment: "Author：") + asset.createdByName
        
        if let date = asset.createdDate {
            let dateString = Utils.dateTimeFromDate(date)
            self.CreatedAtLabel.text = NSLocalizedString("Created at：", comment: "Created at：)") + dateString
        } else {
            self.CreatedAtLabel.text = NSLocalizedString("Created at：?", comment: "Created at：?")
        }

        let gesture = UITapGestureRecognizer(target:self, action: #selector(AssetDetailViewController.imageViewTapped(_:)))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(gesture)
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

    fileprivate func deleteAsset() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.show(withStatus: NSLocalizedString("Delete item...", comment: "Delete item..."))
        let api = DataAPI.sharedInstance
        let app = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
        
        let success: ((JSON?)-> Void) = {
            (result: JSON?)-> Void in
            LOG("\(result!)")
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.dismiss()
            
            let defaultCenter = NotificationCenter.default
            defaultCenter.post(name: Notification.Name(rawValue: MTIAssetDeletedNotification), object: nil, userInfo: ["asset":self.asset])

            _ = self.navigationController?.popViewController(animated: true)
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            LOG("failure:\(error!.description)")
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.showError(withStatus: error!["message"].stringValue)
        }
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                api.deleteAsset(siteID: self.asset.blogID, assetID: self.asset.id, success: success, failure: failure)
            },
            failure: failure
        )
    }
    
    @IBAction func deleteButtonPushed(_ sender: AnyObject) {
        let alertController = UIAlertController(
            title: NSLocalizedString("Delete Item", comment: "Delete Item"),
            message: NSLocalizedString("Are you sure you want to delete the Item?", comment: "Are you sure you want to delete the Item?"),
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .destructive) {
            action in
            self.deleteAsset()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) {
            action in
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func imageViewTapped(_ recognizer: UIGestureRecognizer) {
        let vc = ImageViewController()
        vc.asset = asset
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
