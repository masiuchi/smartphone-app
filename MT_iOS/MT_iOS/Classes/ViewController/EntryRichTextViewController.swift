//
//  EntryRichTextViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/05.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import ZSSRichTextEditor

class EntryRichTextViewController: MTRichTextEditor {

    var object: EntryTextAreaItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        
        self.title = object.label
        self.setHTML(object.text)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(EntryRichTextViewController.saveButtonPushed(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_arw"), left: true, target: self, action: #selector(EntryRichTextViewController.backButtonPushed(_:)))
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
    
    private func sourceView()-> ZSSTextView? {
        for view in self.view.subviews {
            if view is ZSSTextView {
                return view as? ZSSTextView
            }
        }
        return nil
    }
    
    @IBAction func saveButtonPushed(sender: UIBarButtonItem) {
        if let sourceView = self.sourceView() {
            if !sourceView.hidden {
                self.setHTML(sourceView.text)
            }
        }
        object.text = self.getHTML()
        object.isDirty = true
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func backButtonPushed(sender: UIBarButtonItem) {
        if let sourceView = self.sourceView() {
            if !sourceView.hidden {
                self.setHTML(sourceView.text)
            }
        }
        if self.getHTML() == object.text {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        Utils.confrimSave(self)
    }
}
