//
//  CommonWebViewController.swift
//  SenseiNote
//
//  Created by CHEEBOW on 2015/01/09.
//  Copyright (c) 2015年 LOUPE,Inc. All rights reserved.
//

import UIKit
import SVProgressHUD
import WebKit

class CommonWebViewController: BaseViewController, WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView!
    var urlString: String = ""
    var filePath: String = ""
    var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.webView = WKWebView(frame: self.view.bounds)
        self.view.addSubview(self.webView)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.backgroundColor = Color.bg
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: self.webView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0.0)
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: self.webView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0.0)
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: self.webView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self.topLayoutGuide,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0.0)
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: self.webView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.bottomLayoutGuide,
            attribute: .top,
            multiplier: 1.0,
            constant: 0.0)
        
        self.view.addConstraints([leading, trailing, top, bottom])
        
        if filePath.isEmpty {
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!)
            
            self.webView.load(request as URLRequest)
        } else {
            do {
                let html = try String(contentsOfFile: filePath,
                    encoding: String.Encoding.utf8)
                self.webView.loadHTMLString(html, baseURL: nil)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.webView.addSubview(self.indicator)
        self.indicator.center = self.webView.center
        var rect = self.indicator.frame
        if (self.navigationController != nil) {
            rect.origin.y -= self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height
        }
        self.indicator.frame = rect
        self.indicator.startAnimating()
        
        self.title = NSLocalizedString("Loading...", comment: "Loading...")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Utils.hasConnectivity() {
            SVProgressHUD.showError(withStatus: NSLocalizedString("You can not connect to the network.", comment: "You can not connect to the network."))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK:-
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.indicator.removeFromSuperview()
        let title = webView.title
        self.title = title
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    fileprivate func didFail(_ error: NSError) {
        self.indicator.removeFromSuperview()
        if error.code != -999 {
            self.title = NSLocalizedString("Error", comment: "Error")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.didFail(error as NSError)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.didFail(error as NSError)
    }
}
