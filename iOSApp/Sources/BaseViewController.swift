//
//  BaseViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 12/4/16.
//  Copyright © 2016 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit

/////////////////////////////////////////////////////////////////////////////////
// BaseViewController - base class
//
class BaseViewController : UIViewController
{
    // logging
    var loggingEnabled : Bool = false

    // view data download
    var downloadEnabled : Bool = true
    var defaultDownloadUrl : String?
    var dataDownloads = [String: DownloadTask]()
    var downloadBusyIndicatorShown : Bool = false
    var downloadHint : String = "Downloading..."
    lazy var downloadSession : URLSession = {
        let session =  URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        return session
    }()
    
    // view deeplink
    var deepLinkUrl : String? = nil
    var deepLinkResourceName : String? = nil
    
    // functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let url = self.defaultDownloadUrl {
            let download = JSONDownloadTask.init(urlPath: url, completionJSONhandler: nil)
            dataDownloads[url] = download;
        }
        
        if self.downloadEnabled {
            self.startDataDownloadTasks()
        }
    }
    // Data download functions
    func isDownloading() -> Bool
    {
        if dataDownloads.count == 0 {
            return false
        }
        for download in dataDownloads.values {
            if download.status == .Downloading {
                return true
            }
        }
        return false
    }
    func updateDownloadUIStatus() -> Void
    {
        DispatchQueue.main.async {
            if self.isDownloading() {
                if !self.downloadBusyIndicatorShown {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    SwiftSpinner.show(self.downloadHint, animated: true)
                    self.downloadBusyIndicatorShown = true
                }
            }else{
                if self.downloadBusyIndicatorShown {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    SwiftSpinner.hide()
                    self.downloadBusyIndicatorShown = false
                }
            }
        }
        
    }
    func startDataDownloadTasks() {
        if dataDownloads.count == 0 {
            return
        }
        _ = self.downloadSession // Now create the download session
        for download in dataDownloads.values {
            download.downloadTask = self.downloadSession.dataTask(with: download.urlRequest, completionHandler: {
                (data, response, error) in
                sleep(5)
                if let err = error { // Network Error
                    download.status = .Error
                    if self.loggingEnabled {
                        NSLog("BaseViewController Network error: \(err.localizedDescription)")
                    }
                    download.callback?(nil, err)
                }else if let httpResponse = response as? HTTPURLResponse{
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 { // HTTP success
                        download.status = .Completed
                        download.callback?(data, nil)
                    }else{
                        download.status = .Error
                        if self.loggingEnabled {
                            NSLog("BaseViewController HTTP server error: \(httpResponse.debugDescription)")
                        }
                        download.callback?(nil, NSError.init(domain: "Error.HTTP", code: httpResponse.statusCode, userInfo: nil))
                    }
                }else{ // Non HTTP response??
                    download.status = .Error
                    if self.loggingEnabled {
                        NSLog("BaseViewController non-HTTP error: \(response.debugDescription)")
                    }
                    download.callback?(nil, NSError.init(domain: DownloadTask.ErrorDomain, code: DownloadTask.ErrorCode.NonHTTPResponse.rawValue, userInfo: nil))
                }
                self.updateDownloadUIStatus()
            })
            download.status = .Downloading
            download.downloadTask?.resume()
        }
        self.updateDownloadUIStatus()
    }
    
}
/////////////////////////////////////////////////////////////////////////////////
// BaseViewController  -- URLSession delegates
extension BaseViewController : URLSessionDelegate
{
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //We've got a URLAuthenticationChallenge - we simply trust the HTTPS server and we proceed
        if self.loggingEnabled{
            NSLog("URLSession didReceive Auth challenge from server \(challenge.debugDescription)")
        }
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        
    }
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        // We've got an error
        if let err = error {
            NSLog("URLSession *** Error \(err.localizedDescription)")
        }else{
            NSLog("URLSession *** Error. Giving up")
        }
    }
}
extension BaseViewController : URLSessionDataDelegate
{
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // We've got an error
        if let err = error {
            NSLog("URLSession *** Error: \(err.localizedDescription)")
        } else {
            NSLog("URLSession *** Error. Giving up")
        }
        
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // We've got the response headers from the server
        if self.loggingEnabled{
            NSLog("URLSession receive HTTP headers \(response.description)")
        }
        completionHandler(URLSession.ResponseDisposition.allow)
        
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // We've got the response body
        if self.loggingEnabled{
            NSLog("URLSession receive HTTP body")
//            if let responseText = String(bytes: data, encoding: .utf8){
//                NSLog("Body: \(responseText)")
//            }
        }

//        if let downloadUrl = dataTask.originalRequest?.url?.absoluteString,
//            let download = self.dataDownloads[downloadUrl] {
//            download.callback?(data, nil)
//        }
    }
}



