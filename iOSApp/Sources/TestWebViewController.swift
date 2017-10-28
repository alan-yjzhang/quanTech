//
//  TestWebViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 4/12/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
class TestWebViewController : WebViewController
{
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadURLWithString("https://www.sina.com.cn")
    }
}

// Example 2: creat webview programmatically
class TestWebViewController2 : UIViewController
{
    var webvc : WebViewController!
    override open func viewDidLoad() {
        super.viewDidLoad()
        webvc = WebViewController()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webvc.loadURLWithString("https://www.sina.com.cn")
        self.navigationController?.pushViewController(webvc, animated: true)
    }
}
