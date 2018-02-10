//
//  EntryTextEditorViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/05.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class EntryTextEditorViewController: BaseViewController, UITextViewDelegate {

    var textView: UITextView!

    var object: EntryTextItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textView = UITextView(frame: self.view.bounds)
        self.textView.autocapitalizationType = UITextAutocapitalizationType.none
        self.textView.autocorrectionType = UITextAutocorrectionType.no
        self.textView.font = UIFont.systemFont(ofSize: 13.0)
        self.textView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.textView.autoresizesSubviews = true
        self.textView.delegate = self
        
        self.view.addSubview(self.textView)
        
        self.title = object.label
        self.textView.text = object.text
        self.textView.selectedRange = NSRange()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(EntryTextEditorViewController.saveButtonPushed(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_arw"), left: true, target: self, action: #selector(EntryTextEditorViewController.backButtonPushed(_:)))

        self.textView.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(EntryTextEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EntryTextEditorViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EntryTextEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
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
        
        var insets = self.textView.contentInset
        insets.bottom = keyboardFrame.size.height
        UIView.animate(withDuration: duration, animations:
            {_ in
                self.textView.contentInset = insets;
            }
        )
    }
    
    func keyboardWillHide(_ notification: Notification) {
        var info = notification.userInfo!
//        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        var insets = self.textView.contentInset
        insets.bottom = 0
        UIView.animate(withDuration: duration, animations:
            {_ in
                self.textView.contentInset = insets;
            }
        )
    }
    
    @IBAction func saveButtonPushed(_ sender: UIBarButtonItem) {
        object.text = textView.text
        object.isDirty = true
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func backButtonPushed(_ sender: UIBarButtonItem) {
        if self.textView.text == object.text {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        Utils.confrimSave(self)
    }

}
