//
//  WebViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 3/7/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//
// From https://github.com/coffellas-cto/GDWebViewController/blob/master/GDWebViewController/GDWebViewController.swift

import Foundation
import WebKit
open class WebViewController : UIViewController, WKUIDelegate, WKNavigationDelegate
{
    open var allowJavaScriptAlerts = true
    fileprivate var webView : WKWebView!
    fileprivate var progressView : UIProgressView!
    fileprivate var toolbarContainer : UIView! // TODO: replace with better toolbar
    fileprivate var toolbarHeightConstraint : NSLayoutConstraint!
    fileprivate var toolbarHeight : CGFloat = 0
    fileprivate var navControllerUseBackSwipe : Bool = false
    
    lazy fileprivate var activityIndicator : UIActivityIndicatorView! = {
       var activityIndicator = UIActivityIndicatorView()
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.2)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicator)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[activityIndicator]-0-|", options: [], metrics: nil, views: ["activityIndicator":activityIndicator]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide]-0-[activityIndicator]-0-[toolbarContainer]|", options: [], metrics: nil, views: ["activityIndicator":activityIndicator, "toolbarContainer":self.toolbarContainer, "topGuide":self.topLayoutGuide]))
        return activityIndicator
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        // Both nibNameOrNil and nibBundleOrNil == nil when called by convenient init()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }
    required public init?(coder aDecoder : NSCoder){ // called by Storyboard
        super.init(coder: aDecoder)
        self.commonInit()
    }
    func commonInit(){
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        toolbarContainer = UIView()
        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false
    }
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        webView.stopLoading()
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup toolbarContainer
        // Set up toolbarContainer
        self.view.addSubview(toolbarContainer)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[toolbarContainer]-0-|", options: [], metrics: nil, views: ["toolbarContainer": toolbarContainer]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[toolbarContainer]-0-|", options: [], metrics: nil, views: ["toolbarContainer": toolbarContainer]))
        toolbarHeightConstraint = NSLayoutConstraint(item: toolbarContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: toolbarHeight)
        toolbarContainer.addConstraint(toolbarHeightConstraint)
        
        // Set up webView
        self.view.addSubview(webView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[webView]-0-|", options: [], metrics: nil, views: ["webView": webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide]-0-[webView]-0-[toolbarContainer]|", options: [], metrics: nil, views: ["webView": webView, "toolbarContainer": toolbarContainer, "topGuide": self.topLayoutGuide]))
        
    }
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
//        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
//        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
//        webView.removeObserver(self, forKeyPath: "URL")
//        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "loading")
    }
    //
    // Public methods -- navigate to an URL
    //
    open func loadURLWithString(_ URLString: String) {
        if let URL = URL(string: URLString) {
            if (URL.scheme != "") && (URL.host != nil) {
                loadURL(URL)
            } else {
                loadURLWithString("http://\(URLString)")
            }
        }
    }
    
    /**
     Navigates to the URL.
     - parameter URL: The URL for a request.
     - parameter cachePolicy: The cache policy for a request. Optional. Default value is .UseProtocolCachePolicy.
     - parameter timeoutInterval: The timeout interval for a request, in seconds. Optional. Default value is 0.
     */
    open func loadURL(_ URL: Foundation.URL, cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 0) {
        webView.load(URLRequest(url: URL, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval))
    }
    
    /**
     Evaluates the given JavaScript string.
     - parameter javaScriptString: The JavaScript string to evaluate.
     - parameter completionHandler: A block to invoke when script evaluation completes or fails.
     
     The completionHandler is passed the result of the script evaluation or an error.
     */
    open func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((AnyObject?, NSError?) -> Void)?) {
        webView.evaluateJavaScript(javaScriptString, completionHandler: completionHandler as! ((Any?, Error?) -> Void)?)
    }
    
    // Toolbar shows
    open var showsToolbar: Bool {
        get{
            return self.toolbarHeight != 0
        }
        set{
            self.toolbarHeight = newValue ? 44: 0
        }
    }
    open func showToolbar(_ show:Bool, animated: Bool){
        self.showsToolbar = show
        if toolbarHeightConstraint != nil {
            toolbarHeightConstraint.constant = self.toolbarHeight
            if animated{
                UIView.animate(withDuration: 0.2, animations: { 
                    self.view.layoutIfNeeded()
                })
            }else{
                self.view.layoutIfNeeded()
            }
        }
    }
    // Loading indications
    fileprivate func showLoading(_ animated: Bool){
        if animated {
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
    }
    fileprivate func showError(_ errorTitle: String?, errorMessage: String?){
        let alertView = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    fileprivate func progressChanged(_ newValue : NSNumber){
        if progressView == nil {
            progressView = UIProgressView()
            progressView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(progressView)
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[progressView]-0-|", options: [], metrics: nil, views: ["progressView":progressView]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide]-0-[progressView(2)]", options: [], metrics: nil, views: ["progressView":progressView, "topGuide":self.topLayoutGuide]))
        }
        progressView.progress = newValue.floatValue
        if progressView.progress == 1 {
            progressView.progress = 0
            UIView.animate(withDuration: 0.2, animations: { 
                self.progressView.alpha = 0
            })
        }else if progressView.alpha == 0 {
            UIView.animate(withDuration: 0.2, animations: { 
                self.progressView.alpha = 1
            })
        }
    }
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {return}
        switch keyPath {
        case "estimatedProgress":
            if let newValue = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                progressChanged(newValue)
            }
//        case "URL":
//            delegate?.webViewController?(self, didChangeURL: webView.url)
//        case "title":
//            delegate?.webViewController?(self, didChangeTitle: webView.title as NSString?)
        case "loading":
            if let val = change?[NSKeyValueChangeKey.newKey] as? Bool {
                if !val {
                    showLoading(false)
//                    backForwardListChanged()
//                    delegate?.webViewController?(self, didFinishLoading: webView.url)
                }
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    // Override this property getter to show bottom toolbar above other toolbars
    override open var edgesForExtendedLayout: UIRectEdge {
        get {
            return UIRectEdge(rawValue: super.edgesForExtendedLayout.rawValue ^ UIRectEdge.bottom.rawValue)
        }
        set {
            super.edgesForExtendedLayout = newValue
        }
    }
    
    // MARK: WKNavigationDelegate Methods
    
    open func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showLoading(false)
        if error._code == NSURLErrorCancelled {
            return
        }
        
        showError("Error", errorMessage: error.localizedDescription)
    }
    
    open func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showLoading(false)
        if error._code == NSURLErrorCancelled {
            return
        }
        showError("Error", errorMessage: error.localizedDescription)
    }
    

    open func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    }
    
    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoading(true)
    }
    
    
    // MARK: WKUIDelegate Methods
    
    open func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if !allowJavaScriptAlerts {
            return
        }
        
        let alertController: UIAlertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {(action: UIAlertAction) -> Void in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
