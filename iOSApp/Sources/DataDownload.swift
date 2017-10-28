//
//  DataDownload.swift
//  eduDemo
//
//  Created by Alan Zhang on 1/31/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
typealias completionHandler = (_ result:Data?, _ error: Error?) -> Void
typealias completionJSONHandler = (_ result:Any?, _ error: Error?) -> Void
typealias completionXMLHandler = (_ result:AEXMLDocument?, _ error: Error?) -> Void

class DownloadTask
{
    static let ErrorDomain : String = "Error.DataDownload"
    ///////////////////////////
    enum DownloadStatus  {
        case None, Downloading, Paused, Cancelled, Completed, Error
    }
    enum ErrorCode : Int {
        case NonHTTPResponse=1, InvalidJSONObj = 2, InvalidXMLObj = 3, Cancelled = 999
    }
    ///////////////////////////
    var urlRequest : URLRequest
    var progress: Float = 0.0
    var status : DownloadStatus = .None
    
    var downloadTask : URLSessionDataTask?
    
    var callback : completionHandler? = nil
    init(urlRequest:URLRequest, completion : completionHandler?) {
        self.urlRequest = urlRequest
        self.urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        // here is to add some custom headers
        self.callback = completion
    }
    func pause() -> Void{
        self.downloadTask?.suspend()
        self.status = .Paused
    }
    func cancel() -> Void{
        self.downloadTask?.cancel()
        self.status = .Cancelled
        self.callback?(nil, NSError.init(domain: DownloadTask.ErrorDomain, code: DownloadTask.ErrorCode.Cancelled.rawValue, userInfo: nil))
    }
}
// JSON sample = "https://raw.githubusercontent.com/evermeer/AlamofireJsonToObjects/master/AlamofireJsonToObjectsTests/sample_json"
// XML sample = "https://raw.githubusercontent.com/evermeer/AlamofireXmlToObjects/master/AlamofireXmlToObjectsTests/sample_xml"

class JSONDownloadTask : DownloadTask
{
    init?(urlPath: String, completionJSONhandler : completionJSONHandler?) {
        let wrapperFunc : (Data?, Error?) -> Void  = {
            (result:Data?, error:Error?) in
            guard error == nil else{
                completionJSONhandler?(nil, error)
                return
            }
            guard let obj = try? JSONSerialization.jsonObject(with: result!, options: []) else{
                completionJSONhandler?(nil, NSError.init(domain: DownloadTask.ErrorDomain, code: DownloadTask.ErrorCode.InvalidJSONObj.rawValue, userInfo: nil))
                return
            }
            completionJSONhandler?(obj, nil)
        }
        guard let url = URL.init(string: urlPath) else{
            return nil
        }
        var urlRequest = URLRequest.init(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        super.init(urlRequest: urlRequest, completion: wrapperFunc)
    }
}
class XMLDownloadTask : DownloadTask
{
    init?(urlPath: String, completionXMLhandler : completionXMLHandler?) {
        let wrapperFunc : (Data?, Error?) -> Void  = {
            (result:Data?, error:Error?) in
            guard error == nil else{
                completionXMLhandler?(nil, error)
                return
            }
            guard let xmlobj = try? AEXMLDocument.init(xml: result!) else{
                completionXMLhandler?(nil, NSError.init(domain: DownloadTask.ErrorDomain, code: DownloadTask.ErrorCode.InvalidXMLObj.rawValue, userInfo: nil))
                return
            }
            completionXMLhandler?(xmlobj, nil)
        }
        guard let url = URL.init(string: urlPath) else{
            return nil
        }
        var urlRequest = URLRequest.init(url: url)
        urlRequest.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/xml", forHTTPHeaderField: "Accept")
        super.init(urlRequest: urlRequest, completion: wrapperFunc)
    }
}

