//
//  TestBaseViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 4/12/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
class TestBaseViewController: BaseViewController {
    var classURL : String? = nil
    var courseId : NSInteger = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadEnabled = true
        self.loggingEnabled = true
        self.defaultDownloadUrl = "https://raw.githubusercontent.com/evermeer/AlamofireJsonToObjects/master/AlamofireJsonToObjectsTests/sample_json"
        // Do any additional setup after loading the view, typically from a nib.
        let xmlUrl = "https://raw.githubusercontent.com/evermeer/AlamofireXmlToObjects/master/AlamofireXmlToObjectsTests/sample_xml"
        self.dataDownloads[xmlUrl] = XMLDownloadTask.init(urlPath: xmlUrl, completionXMLhandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
