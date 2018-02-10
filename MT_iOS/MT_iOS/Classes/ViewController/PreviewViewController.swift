//
//  PreviewViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/21.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit
import SVProgressHUD
import WebKit

class PreviewViewController: BaseViewController, WKUIDelegate, WKNavigationDelegate {
    var url: String!
    var html: String?
    
    var webView: WKWebView!
    var segmentedControl: UISegmentedControl!
    var indicator: UIActivityIndicatorView!
    var processPool: WKProcessPool!
    
    fileprivate func makeWebView() {
        if self.webView != nil {
            self.webView.removeFromSuperview()
        }
        
        self.processPool = WKProcessPool()
        
        if segmentedControl.selectedSegmentIndex == 1 {
            var js = ""
            js += "var metalist = document.getElementsByTagName('meta');"
            js += "for(var i = 0; i < metalist.length; i++) {"
            js += "  var name = metalist[i].getAttribute('name');"
            js += "  if(name && name.toLowerCase() === 'viewport') {"
            js += "    metalist[i].setAttribute('content', 'width=1024px');"
            js += "    break;"
            js += "  }"
            js += "}"

            let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            
            let controller = WKUserContentController()
            controller.addUserScript(userScript)
            
            let configuration = WKWebViewConfiguration()
            configuration.userContentController = controller
            configuration.processPool = self.processPool;
            
            self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        } else {
            let configuration = WKWebViewConfiguration()
            configuration.processPool = self.processPool;
            
            self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        }
        
        //self.webView.scalesPageToFit = true
        self.view.addSubview(self.webView)

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
        
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.webView.addSubview(self.indicator)
        self.indicator.center = self.webView.center
        var rect = self.indicator.frame
        if (self.navigationController != nil) {
            rect.origin.y -= self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height
        }
        self.indicator.frame = rect

        self.webView.addSubview(self.indicator)
        
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_close"), left: true, target: self, action: #selector(PreviewViewController.closeButtonPushed(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let items = [
            NSLocalizedString("Mobile", comment: "Mobile"),
            NSLocalizedString("PC", comment: "PC"),
        ]
        
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl .addTarget(self, action: #selector(PreviewViewController.segmentedControlChanged(_:)), for: UIControlEvents.valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        self.navigationItem.titleView = segmentedControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userAgentChange(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.indicator.isHidden = true
        if !Utils.hasConnectivity() {
            SVProgressHUD.showError(withStatus: NSLocalizedString("You can not connect to the network.", comment: "You can not connect to the network."))
        }
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

    fileprivate func userAgentChange(_ mobile: Bool) {
        var dic = [String: String]()
        if mobile {
            dic = ["UserAgent": "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X; en-us) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53"]
        } else {
            dic = ["UserAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8) AppleWebKit/536.25 (KHTML, like Gecko) Version/7.0 Safari/536.25"]
        }
        
        UserDefaults.standard.register(defaults: dic)

        self.makeWebView()
        
        if html == nil {
            let escapedURL = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let request = NSMutableURLRequest(url: URL(string: escapedURL!)!)
            self.webView.load(request as URLRequest)
        } else {
            self.webView.loadHTMLString(html!, baseURL: nil)
        }
    }
    
    func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: //Mobile
            userAgentChange(true)
        case 1: //PC
            userAgentChange(false)
        default:
            break
        }
    }
    
    //MARK:-
    fileprivate func loadStart() {
        self.indicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    fileprivate func loadFinish() {
        self.indicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.loadStart()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadFinish()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.loadFinish()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.loadFinish()
    }
    
    //MARK: -
    func closeButtonPushed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
