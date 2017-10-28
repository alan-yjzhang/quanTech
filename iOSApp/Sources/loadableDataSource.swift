//
//  loadableDataSource.swift
//  eduDemo
//
//  Created by Alan Zhang on 12/4/16.
//  Copyright © 2016 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit

class loadableDataSource
{
    var loadingInProgress : Bool = false
    var analyticResourceId : String = ""
    var dataSourceUrl : String = ""
    var queryParams : [String: String] = [:]
    var format : String = ""
    
//    var progressSpinnerView : UIView 
    
    var loadErrorCallback : (Error) -> Void = { (error:Error) -> Void in }
    var loadSuccessCallback : (Any?) -> Void = { (result:Any?) -> Void in }
    var task : URLSessionTask?
    
    init(){
        task = nil
    }
    func start(){
        let url = URL.init(string: dataSourceUrl, relativeTo: nil)
        var request = URLRequest.init(url: url!)
        request.httpMethod = "GET"
        
        if format == "JSON" {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }else  if format == "XML" {
            request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
            request.addValue("application/xml", forHTTPHeaderField: "Accept")
        }else{
            print("Unsupported format : \(format)")
            return
        }
        // If needed you could add Authorization header value
        // Add Basic Authorization
        /*
         let username = "myUserName"
         let password = "myPassword"
         let loginString = NSString(format: "%@:%@", username, password)
         let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
         let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
         request.setValue(base64LoginString, forHTTPHeaderField: "Authorization")
         */
        loadingInProgress = true;
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, urlResponse, error in
            self.loadingInProgress = false;
            if error != nil {
                self.loadErrorCallback(error!)
                return
            }
            if self.format == "JSON" {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSArray
                    self.loadSuccessCallback(json)
                } catch {
                    print(error)
                }
            }
            if self.format == "XML" {
                self.loadSuccessCallback(data)
            }
            
        }
        task.resume()
    }
    func cancel(){
        task?.cancel()
        loadingInProgress = false;
        let error : NSError = NSError.init(domain: "loadableDataSource", code: -1, userInfo: nil)
        self.loadErrorCallback(error)
    }
}
