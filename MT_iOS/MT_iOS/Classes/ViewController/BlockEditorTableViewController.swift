//
//  BlockEditorTableViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/10.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import MMMarkdown
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class BlockEditorTableViewController: BaseTableViewController, AddAssetDelegate {
    var blog: Blog!
    var entry: BaseEntry!
    var blocks: EntryBlocksItem!
    var items: [BaseEntryItem]!
    var addedImageFiles: [String]!
    var entryAddedImageFiles: stringArray!
    
    var noItemLabel = UILabel()
    var tophImage = UIImageView(image: UIImage(named: "guide_toph_sleep"))
    var guidanceBgView = UIView()
    
    fileprivate var oldHTML: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = blocks.label

        items = [BaseEntryItem]()
        for block in blocks.blocks {
            if block is BlockImageItem {
                let item = BlockImageItem()
                item.asset = (block as! BlockImageItem).asset
                item.imageFilename = (block as! BlockImageItem).imageFilename
                item.label = block.label
                items.append(item)
            } else {
                let item = BlockTextItem()
                item.text = (block as! BlockTextItem).text
                item.label = block.label
                item.format = self.entry.editMode
                items.append(item)
            }
        }
        addedImageFiles = [String]()
        
        self.tableView.register(UINib(nibName: "TextBlockTableViewCell", bundle: nil), forCellReuseIdentifier: "TextBlockTableViewCell")
        self.tableView.register(UINib(nibName: "ImageBlockTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageBlockTableViewCell")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(BlockEditorTableViewController.saveButtonPushed(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_arw"), left: true, target: self, action: #selector(BlockEditorTableViewController.backButtonPushed(_:)))

        self.view.addSubview(tophImage)
        tophImage.center = view.center
        var frame = tophImage.frame
        frame.origin.y = 109.0
        tophImage.frame = frame
        
        noItemLabel.textColor = Color.placeholderText
        noItemLabel.font = UIFont.systemFont(ofSize: 18.0)
        noItemLabel.text = String(format: NSLocalizedString("No %@", comment: "No %@"), arguments: [blocks.label])
        noItemLabel.sizeToFit()
        self.view.addSubview(noItemLabel)
        noItemLabel.center = view.center
        frame = noItemLabel.frame
        frame.origin.y = tophImage.frame.origin.y + tophImage.frame.size.height + 13.0
        noItemLabel.frame = frame
        
        tophImage.isHidden = true
        noItemLabel.isHidden = true
        
        guidanceBgView.backgroundColor = colorize(0x000000, alpha: 0.3)
        let app = UIApplication.shared.delegate as! AppDelegate
        guidanceBgView.frame = app.window!.frame
        app.window!.addSubview(guidanceBgView)
        
        let guidanceView = BlockGuidanceView.instanceFromNib() as! BlockGuidanceView
        guidanceView.closeButton.addTarget(self, action: #selector(BlockEditorTableViewController.guidanceCloseButtonPushed(_:)), for: UIControlEvents.touchUpInside)
        guidanceBgView.addSubview(guidanceView)
        guidanceView.center = guidanceBgView.center
        frame = guidanceView.frame
        frame.origin.y = 70.0
        guidanceView.frame = frame
        
        let defaults = UserDefaults.standard
        let showed = defaults.bool(forKey: "blocksGuidanceShowed")
        if showed {
            guidanceBgView.removeFromSuperview()
        }
                
        self.tableView.backgroundColor = Color.tableBg
        
        oldHTML = self.makeItemsHTML()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.makeToolbarItems(false)
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if items == nil {
            return 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if items == nil {
            return 0
        }
        
        tophImage.isHidden = !(items.count == 0)
        noItemLabel.isHidden = !(items.count == 0)

        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        // Configure the cell...
        let item = items[indexPath.row]
        
        if item.type == "textarea" {
            let c = tableView.dequeueReusableCell(withIdentifier: "TextBlockTableViewCell", for: indexPath) as! TextBlockTableViewCell
            let text = item.dispValue()
            if text.isEmpty {
                c.placeholderLabel?.text = (item as! EntryTextAreaItem).placeholder()
                c.placeholderLabel.isHidden = false
                c.blockTextLabel.isHidden = true
            } else {
                c.blockTextLabel?.text = Utils.removeHTMLTags(text)
                c.placeholderLabel.isHidden = true
                c.blockTextLabel.isHidden = false
            }
            cell = c
        } else {
            let c = tableView.dequeueReusableCell(withIdentifier: "ImageBlockTableViewCell", for: indexPath) as! ImageBlockTableViewCell
            if (item as! EntryImageItem).asset != nil {
                c.blockImageView.sd_setImage(with: URL(string: item.dispValue()))
            } else {
                LOG(item.dispValue())
                c.blockImageView.image = UIImage(contentsOfFile: item.dispValue())
            }
            cell = c
        }
        
        self.adjustCellLayoutMargins(cell)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

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

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = items[sourceIndexPath.row];
        items.remove(at: sourceIndexPath.row);
        items.insert(item, at: destinationIndexPath.row)
    }
    
    fileprivate func showHTMLEditor(_ object: BlockTextItem) {
        object.format = self.entry.editMode
        if self.entry.editMode == Entry.EditMode.plainText {
            let vc = EntryHTMLEditorViewController()
            vc.object = object
            vc.blog = blog
            vc.entry = entry
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.entry.editMode == Entry.EditMode.markdown {
            let vc = EntryMarkdownEditorViewController()
            vc.object = object
            vc.blog = blog
            vc.entry = entry
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = EntryRichTextViewController()
            vc.object = object
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    fileprivate func showAssetSelector(_ object: EntryImageItem) {
        if object.id.isEmpty {
            self.showOfflineImageSelector(object)
        } else {
            self.showImageSelector(object)
        }
    }
    
    fileprivate func showImageSelector(_ object: EntryImageItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "ImageSelector", bundle: nil)
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nav.topViewController as! ImageSelectorTableViewController
        vc.blog = blog
        vc.delegate = self
        vc.showAlign = true
        vc.object = object
        vc.entry = self.entry
        self.present(nav, animated: true, completion: nil)
    }
    
    fileprivate func showOfflineImageSelector(_ object: EntryImageItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "OfflineImageSelector", bundle: nil)
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nav.topViewController as! OfflineImageSelectorTableViewController
        vc.blog = blog
        vc.delegate = self
        vc.showAlign = true
        vc.object = object
        vc.entry = self.entry
        self.present(nav, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let items = self.items {
            let item = items[indexPath.row]
            
            if item.type == "textarea"  {
                self.showHTMLEditor(item as! BlockTextItem)
            } else if item.type == "image" {
                self.showAssetSelector(item as! BlockImageItem)
            }
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
    
    @IBAction func saveButtonPushed(_ sender: UIBarButtonItem) {
        blocks.blocks = self.items
        blocks.isDirty = true
        for filename in addedImageFiles {
            entryAddedImageFiles.items.append(filename)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }

    fileprivate func makeToolbarItems(_ editMode: Bool) {
        var buttons = [UIBarButtonItem]()
        if editMode {
            let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(BlockEditorTableViewController.doneButtonPushed(_:)))
            
            buttons = [flexible, doneButton]
        } else {
            let cameraButton = UIBarButtonItem(image: UIImage(named: "btn_camera"), left: true, target: self, action: #selector(BlockEditorTableViewController.cameraButtonPushed(_:)))
            let textAddButton = UIBarButtonItem(image: UIImage(named: "btn_textadd"), left: false, target: self, action: #selector(BlockEditorTableViewController.textAddButtonPushed(_:)))
            
            let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            
            let previewButton = UIBarButtonItem(image: UIImage(named: "btn_preview"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BlockEditorTableViewController.previewButtonPushed(_:)))

            let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(BlockEditorTableViewController.editButtonPushed(_:)))
            
            buttons = [cameraButton, textAddButton, flexible, previewButton, editButton]

        }
        
        self.setToolbarItems(buttons, animated: true)
    }

    @IBAction func editButtonPushed(_ sender: UIBarButtonItem) {
        self.tableView.setEditing(true, animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.makeToolbarItems(true)
    }

    @IBAction func doneButtonPushed(_ sender: UIBarButtonItem) {
        self.tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.makeToolbarItems(false)
    }
    
    @IBAction func cameraButtonPushed(_ sender: UIBarButtonItem) {
        let item = BlockImageItem()
        item.label = NSLocalizedString("Image", comment: "Image")
        self.tableView.reloadData()

        self.showAssetSelector(item)
    }
    
    func AddAssetDone(_ controller: AddAssetTableViewController, asset: Asset) {
        self.dismiss(animated: false, completion: {
            let vc = controller as! ImageSelectorTableViewController
            let item = vc.object
            item?.asset = asset
            (item as! BlockImageItem).align = controller.imageAlign
            if self.items.index(of: item!) < 0 {
                self.items.append(item!)
            }
            self.tableView.reloadData()
        })
    }
    
    func AddAssetsDone(_ controller: AddAssetTableViewController) {
    }
    
    func AddOfflineImageDone(_ controller: AddAssetTableViewController, item: EntryImageItem) {
        self.dismiss(animated: false, completion: {
            item.asset = nil
            (item as! BlockImageItem).align = controller.imageAlign
            if self.items.index(of: item) < 0 {
                self.items.append(item)
            }
            self.addedImageFiles.append((item as! BlockImageItem).imageFilename)
            self.tableView.reloadData()
        })
    }
    
    func AddOfflineImageStorageError(_ controller: AddAssetTableViewController, item: EntryImageItem) {
        self.dismiss(animated: false, completion: {
            let alertController = UIAlertController(
                title: NSLocalizedString("Error", comment: "Error"),
                message: NSLocalizedString("The selected image could not be saved to the storage.", comment: "The selected image could not be saved to the storage."),
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) {
                action in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    @IBAction func textAddButtonPushed(_ sender: UIBarButtonItem) {
        let item = BlockTextItem()
        item.label = NSLocalizedString("Text", comment: "Text")
        items.append(item)
        self.tableView.reloadData()
        
        self.showHTMLEditor(item)
    }
    
    @IBAction func previewButtonPushed(_ sender: UIBarButtonItem) {
        let vc = PreviewViewController()
        let nav = UINavigationController(rootViewController: vc)
        let html = self.makeHTML()
        vc.html = html
        self.present(nav, animated: true, completion: nil)
    }

    func makeItemsHTML()-> String {
        var html = ""
        for item in items {
            if item is BlockImageItem {
                html += item.value() + "\n\n"
            } else {
                if self.entry.editMode == Entry.EditMode.markdown {
                    let sourceText = item.value()
                    do {
                        let markdown = try MMMarkdown.htmlString(withMarkdown: sourceText, extensions: MMMarkdownExtensions.gitHubFlavored)
                        html += markdown + "\n\n"
                    } catch _ {
                        html += sourceText + "\n\n"
                    }
                } else {
                    html += "<p>" + item.value() + "</p>" + "\n\n"
                }
            }
        }
        return html
    }
    
    func makeHTML()-> String {
        var html = "<!DOCTYPE html><html><head><title>Preview</title><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"></head><body>"
        
        html += self.makeItemsHTML()

        html += "</body></html>"

        return html
    }
    
    func cleanup() {
        for path in self.addedImageFiles {
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
            }
        }
    }

    @IBAction func backButtonPushed(_ sender: UIBarButtonItem) {
        if self.makeItemsHTML() == oldHTML {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
                
        Utils.confrimSave(self, block:{self.cleanup()})
    }
    
    func guidanceCloseButtonPushed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3,
            animations:
            {_ in
                self.guidanceBgView.alpha = 0.0
            },
            completion:
            {_ in
                self.guidanceBgView.removeFromSuperview()
                
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "blocksGuidanceShowed")
                defaults.synchronize()
            }
        )
    }

}
