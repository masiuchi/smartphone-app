//
//  AddAssetTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/10.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import MobileCoreServices
import SVProgressHUD
import SwiftyJSON
import AVFoundation
import AssetsLibrary
import QBImagePickerController

protocol AddAssetDelegate {
    func AddOfflineImageDone(_ controller: AddAssetTableViewController, item: EntryImageItem)
    func AddOfflineImageStorageError(_ controller: AddAssetTableViewController, item: EntryImageItem)
    func AddAssetDone(_ controller: AddAssetTableViewController, asset: Asset)
    func AddAssetsDone(_ controller: AddAssetTableViewController)
}

class AddAssetTableViewController: BaseTableViewController, BlogImageSizeDelegate, BlogImageQualityDelegate, BlogUploadDirDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageAlignDelegate, QBImagePickerControllerDelegate, UploaderTableViewControllerDelegate {
    enum Section:Int {
        case buttons = 0,
        items,
        _Num
    }
    
    enum Item:Int {
        case uploadDir = 0,
        size,
        quality,
        align,
        _Num
    }
    
    var blog: Blog!
    var delegate: AddAssetDelegate?
    
    var uploadDir = "/"
    var imageSize = Blog.ImageSize.m
    var imageQuality = Blog.ImageQuality.normal
    var imageAlign = Blog.ImageAlign.none
    var imageCustomWidth = 0
    
    var showAlign = false
    
    var multiSelect = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = NSLocalizedString("Add Item", comment: "Add Item")
        
        self.tableView.backgroundColor = Color.tableBg
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_close"), left: true, target: self, action: #selector(AddAssetTableViewController.closeButtonPushed(_:)))
        
        uploadDir = blog.uploadDir
        imageSize = blog.imageSize
        imageQuality = blog.imageQuality
        imageCustomWidth =  blog.imageCustomWidth

        self.multiSelect = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return Section._Num.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case Section.buttons.rawValue:
            return 1
        case Section.items.rawValue:
            if showAlign {
                return Item._Num.rawValue
            } else {
                return Item._Num.rawValue - 1
            }
        default:
            return 0
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.buttons.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) 
            
            self.adjustCellLayoutMargins(cell)
            
            cell.backgroundColor = Color.tableBg
            
            if let cameraButton = cell.viewWithTag(1) as? UIButton {
                cameraButton.addTarget(self, action: #selector(AddAssetTableViewController.cameraButtonPushed(_:)), for: UIControlEvents.touchUpInside)
            }
            if let cameraLabel = cell.viewWithTag(11) as? UILabel {
                cameraLabel.text = NSLocalizedString("Take a photo", comment: "Take a photo")
            }
            
            if let libraryButton = cell.viewWithTag(2) as? UIButton {
                libraryButton.addTarget(self, action: #selector(AddAssetTableViewController.libraryButtonPushed(_:)), for: UIControlEvents.touchUpInside)
            }
            if let libraryLabel = cell.viewWithTag(22) as? UILabel {
                libraryLabel.text = NSLocalizedString("Select from library", comment: "Select from library")
            }
            
            if let assetListButton = cell.viewWithTag(3) as? UIButton {
                assetListButton.addTarget(self, action: #selector(AddAssetTableViewController.assetListButtonPushed(_:)), for: UIControlEvents.touchUpInside)
            }
            if let assetListLabel = cell.viewWithTag(33) as? UILabel {
                assetListLabel.text = NSLocalizedString("Select from Items", comment: "Select from Items")
            }
            
            return cell
        case Section.items.rawValue:
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
            case Item.align.rawValue:
                cell.textLabel?.text = NSLocalizedString("Align", comment: "Align")
                cell.imageView?.image = UIImage(named: "ico_align")
                cell.detailTextLabel?.text = imageAlign.label()
            default:
                cell.textLabel?.text = ""
            }
            
            // Configure the cell...
            
            return cell
        default:
            break
        }
    
        // Configure the cell...

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case Section.buttons.rawValue:
            return 220.0
        case Section.items.rawValue:
            return 58.0
        default:
            return 0
        }
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
        if indexPath.section == Section.buttons.rawValue {
            return
        }
        
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
        case Item.align.rawValue:
            let storyboard: UIStoryboard = UIStoryboard(name: "ImageAlign", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! ImageAlignTableViewController
            vc.selected = imageAlign.rawValue
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
    
    func imageAlignDone(_ controller: ImageAlignTableViewController, selected: Int) {
        imageAlign = Blog.ImageAlign(rawValue: selected)!
        self.tableView.reloadData()
    }
    
    fileprivate func showAlertView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "NotAccessPhotos", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! NotAccessPhotosViewController
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonPushed(_ sender: UIButton) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.showAlertView()
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            self.showAlertView()
            return
        }
        
        let ipc: UIImagePickerController = UIImagePickerController()
        ipc.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            ipc.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            ipc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        ipc.mediaTypes = [kUTTypeImage as String]
        
        self.present(ipc, animated:true, completion:nil)
    }
    
    @IBAction func libraryButtonPushed(_ sender: UIButton) {
        let status = ALAssetsLibrary.authorizationStatus()
        if status == ALAuthorizationStatus.denied || status == ALAuthorizationStatus.restricted {
            self.showAlertView()
            return
        }
        
        if self.multiSelect {
            let ipc: QBImagePickerController = QBImagePickerController()
            ipc.delegate = self
            ipc.allowsMultipleSelection = true
            ipc.maximumNumberOfSelection = 9
            ipc.showsNumberOfSelectedAssets = true
            let types = [
                PHAssetCollectionSubtype.smartAlbumRecentlyAdded.rawValue,
                PHAssetCollectionSubtype.smartAlbumUserLibrary.rawValue,
                PHAssetCollectionSubtype.albumMyPhotoStream.rawValue,
                PHAssetCollectionSubtype.smartAlbumPanoramas.rawValue,
            ]
            ipc.assetCollectionSubtypes = types
            ipc.mediaType = QBImagePickerMediaType.image
            self.present(ipc, animated:true, completion:nil)
        } else {
            let ipc: UIImagePickerController = UIImagePickerController()
            ipc.delegate = self
            ipc.sourceType = UIImagePickerControllerSourceType.photoLibrary
            ipc.mediaTypes = [kUTTypeImage as String]
            self.present(ipc, animated:true, completion:nil)
        }
    }
    
    @IBAction func assetListButtonPushed(_ sender: UIButton) {
        //Implement Subclass
    }
    
    //MARK: - multi select
    private func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {

        self.dismiss(animated: true, completion: {
            let uploader = MultiUploader()
            uploader.blogID = self.blog.id
            uploader.uploadPath = self.uploadDir
            for asset in assets {
                var width = self.imageSize.size()
                if self.imageSize == Blog.ImageSize.custom {
                    width = CGFloat(self.imageCustomWidth)
                }
                uploader.addAsset(asset: asset as! PHAsset, width: width, quality: self.imageQuality.quality() / 100.0)
            }
            
            let vc = UploaderTableViewController()
            vc.mode = .images
            vc.uploader = uploader
            vc.delegate = self
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: false, completion: nil)
        })
    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, shouldSelect asset: PHAsset!) -> Bool {
        if imagePickerController.selectedAssets.count < 8 {
            return true
        } else {
            let alertController = UIAlertController(
                title: nil,
                message: NSLocalizedString("You can upload 8 photos at once.", comment: "You can upload 8 photos at once."),
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) {
                action in
                return
            }
            
            alertController.addAction(okAction)
            
            imagePickerController.present(alertController, animated: true, completion: nil)

            return false
        }
    }
    
    func UploaderFinish(_ controller: UploaderTableViewController) {
        controller.dismiss(animated: false,
            completion: {
                self.delegate?.AddAssetsDone(self)
            }
        )
    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - single select
    fileprivate func uploadData(_ data: Data, filename: String, path: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.show(withStatus: NSLocalizedString("Upload data...", comment: "Upload data..."))
        let api = DataAPI.sharedInstance
        let app = UIApplication.shared.delegate as! AppDelegate
        let authInfo = app.authInfo
        
        let success: ((JSON?)-> Void) = {
            (result: JSON?)-> Void in
            LOG("\(result!)")
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.dismiss()
            
            let asset = Asset(json: result!)
            self.delegate?.AddAssetDone(self, asset: asset)
        }
        let failure: ((JSON?)-> Void) = {
            (error: JSON?)-> Void in
            LOG("failure:\(error!.description)")
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.showError(withStatus: error!["message"].stringValue)
        }
        
        api.authenticationV2(authInfo.username, password: authInfo.password, remember: true,
            success:{_ in
                api.uploadAssetForSite(self.blog.id, assetData: data, fileName: filename, options: ["path":path, "autoRenameIfExists":"true"], success: success, failure: failure)
            },
            failure: failure
        )
    }
    
    fileprivate func uploadImage(_ image: UIImage, date: Date) {
        var width = self.imageSize.size()
        if self.imageSize == Blog.ImageSize.custom {
            width = CGFloat(self.imageCustomWidth)
        }
        let data = Utils.convertJpegData(image, width: width, quality: imageQuality.quality() / 100.0)
        
        let filename = Utils.makeJPEGFilename(date)

        self.uploadData(data, filename: filename, path: uploadDir)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion:
            {_ in
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    if let url = info[UIImagePickerControllerReferenceURL] as? URL {
                        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
                        if let asset = fetchResult.firstObject as PHAsset! {
                            if let date = asset.creationDate {
                                self.uploadImage(image, date: date)
                                return
                            }
                        }
                    }
                    self.uploadImage(image, date: Date())
                }
            }
        );
    }

    
}
