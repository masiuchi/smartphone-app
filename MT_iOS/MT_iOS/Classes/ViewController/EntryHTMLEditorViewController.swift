//
//  EntryHTMLEditorViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/05.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import ZSSRichTextEditor

class EntryHTMLEditorViewController: BaseViewController, UITextViewDelegate, AddAssetDelegate {
    var sourceView: ZSSTextView!

    var object: EntryTextAreaItem!
    var blog: Blog!
    var entry: BaseEntry!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = object.label

        // Do any additional setup after loading the view.
        self.sourceView = ZSSTextView(frame: self.view.bounds)
        self.sourceView.autocapitalizationType = UITextAutocapitalizationType.none
        self.sourceView.autocorrectionType = UITextAutocorrectionType.no
        //self.sourceView.font = UIFont.systemFontOfSize(16.0)
        self.sourceView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.sourceView.autoresizesSubviews = true
        self.sourceView.delegate = self
        self.view.addSubview(self.sourceView)
        
        self.sourceView.text = object.text
        self.sourceView.selectedRange = NSRange()

        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 44.0))
        let modeImage = UIImageView(image: UIImage(named: "ico_html"))
        let modeButton = UIBarButtonItem(customView: modeImage)
        let cameraButton = UIBarButtonItem(image: UIImage(named: "btn_camera"), left: true, target: self, action: #selector(EntryHTMLEditorViewController.cameraButtonPushed(_:)))
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let previewButton = UIBarButtonItem(image: UIImage(named: "btn_preview"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EntryHTMLEditorViewController.previewButtonPushed(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(EntryHTMLEditorViewController.doneButtonPushed(_:)))
        
        if object is BlockTextItem || object.isCustomField {
            toolBar.items = [modeButton, flexibleButton, previewButton, doneButton]
        } else {
            toolBar.items = [cameraButton, modeButton, flexibleButton, previewButton, doneButton]
        }
        self.sourceView.inputAccessoryView = toolBar
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(EntryHTMLEditorViewController.saveButtonPushed(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_arw"), left: true, target: self, action: #selector(EntryHTMLEditorViewController.backButtonPushed(_:)))

        self.sourceView.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(EntryHTMLEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EntryHTMLEditorViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EntryHTMLEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
    
    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        var insets = self.sourceView.contentInset
        insets.bottom = keyboardFrame.size.height
        UIView.animate(withDuration: duration, animations:
            {_ in
                self.sourceView.contentInset = insets;
            }
        )
    }
    
    func keyboardWillHide(_ notification: Notification) {
        var info = notification.userInfo!
//        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        var insets = self.sourceView.contentInset
        insets.bottom = 0
        UIView.animate(withDuration: duration, animations:
            {_ in
                self.sourceView.contentInset = insets;
            }
        )
    }
    
    @IBAction func saveButtonPushed(_ sender: UIBarButtonItem) {
        object.text = sourceView.text
        object.isDirty = true
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func doneButtonPushed(_ sender: UIBarButtonItem) {
        self.sourceView.resignFirstResponder()
    }
    
    fileprivate func showAssetSelector() {
        let storyboard: UIStoryboard = UIStoryboard(name: "ImageSelector", bundle: nil)
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nav.topViewController as! ImageSelectorTableViewController
        vc.blog = blog
        vc.delegate = self
        vc.showAlign = true
        vc.object = EntryImageItem()
        vc.entry = entry
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonPushed(_ sender: UIBarButtonItem) {
        self.showAssetSelector()
    }
    
    func AddAssetDone(_ controller: AddAssetTableViewController, asset: Asset) {
        self.dismiss(animated: false, completion: {
            let vc = controller as! ImageSelectorTableViewController
            let item = vc.object
            item?.asset = asset
            let align = controller.imageAlign
            
            self.object.assets.append(asset)
            
            self.sourceView.replace(self.sourceView.selectedTextRange!, withText: asset.imageHTML(align))
        })
    }
    
    func AddAssetsDone(_ controller: AddAssetTableViewController) {
    }

    func AddOfflineImageDone(_ controller: AddAssetTableViewController, item: EntryImageItem) {
    }
    
    func AddOfflineImageStorageError(_ controller: AddAssetTableViewController, item: EntryImageItem) {
    }
    
    @IBAction func backButtonPushed(_ sender: UIBarButtonItem) {
        if self.sourceView.text == object.text {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        Utils.confrimSave(self)
    }
    
    @IBAction func previewButtonPushed(_ sender: UIBarButtonItem) {
        let vc = PreviewViewController()
        let nav = UINavigationController(rootViewController: vc)

        var html = "<!DOCTYPE html><html><head><title>Preview</title><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"></head><body>"
        
        html += self.sourceView.text
        
        html += "</body></html>"

        vc.html = html
        self.present(nav, animated: true, completion: nil)
    }

}
