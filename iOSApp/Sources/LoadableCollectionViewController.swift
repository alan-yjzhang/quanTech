//
//  LoadableCollectionViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 4/10/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
typealias downloadCompletionBlock = (DataResponse<Any>) -> Void

class LoadableCollectionViewController : UICollectionViewController
{
    // logging
    var loggingEnabled : Bool = false
    var loadingSpinCount = AtomicCounter()
    
    // view data download
    var downloadEnabled : Bool = true
    var defaultLoadingUrl : URLConvertible?
    var downloadAdapter : DownloadAdapter? = DownloadAdapter()
    var downloadBusyIndicatorShown : Bool = false
    var downloadHint : String = "Downloading..."
    lazy var downloadSessionManager : SessionManager = {
        let sessionManager =  Alamofire.SessionManager()
        sessionManager.adapter = self.downloadAdapter
        return sessionManager
    }()
    
    // view deeplink
    var deepLinkUrl : String? = nil
    var deepLinkResourceName : String? = nil
    
    // functions
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.downloadEnabled, let url = self.defaultLoadingUrl {
            self.downloadJSON(url: url, shouldSpin: true, completionJSONHandler: {
                (response) in
                switch(response.result){
                case .success(let JSON):
                    self.defaultLoadingJSONHandler(JSON)
                case .failure(let error):
                    self.defaultLoadingErrorHandler(error: error, response: response.response)
                }
                
            })
        }
    }
    ///////////////////////////////////
    // Collection View update

    
    /////////////////////////////////////////////////////////////////////////////////////
    // data loading
    //
    open func downloadCompleted(){

    }
    open func isBusyLoading() -> Bool
    {
        return self.loadingSpinCount.value() > 0
    }
    open func updateLoadingUIStatus() -> Void
    {
        DispatchQueue.main.async {
            if self.isBusyLoading() == false {
                if self.downloadBusyIndicatorShown {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    SwiftSpinner.hide()
                    self.downloadBusyIndicatorShown = false
                }
                self.downloadCompleted()
            }else{
                if !self.downloadBusyIndicatorShown {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    SwiftSpinner.show(self.downloadHint, animated: true)
                    self.downloadBusyIndicatorShown = true
                }
            }
            self.collectionView?.reloadData()
        }
        
    }
    open func defaultLoadingJSONHandler (_ result: Any?)
    {
        NSLog("%@", result.debugDescription)
    }
    open func defaultLoadingErrorHandler(error: Error?, response: HTTPURLResponse?)
    {
        NSLog("Error=%@ \n response=%@", error?.localizedDescription ?? "", response.debugDescription)
    }
    public func download(url: URLConvertible, shouldSpin: Bool=true, completionHandler: @escaping (DefaultDataResponse) -> Void)
    {
        self.downloadSessionManager.request(url).validate().response { [weak self] (result) in
            guard let strongSelf = self else {return}
            completionHandler(result)
            if shouldSpin {
                strongSelf.loadingSpinCount.decrement()
                if strongSelf.loadingSpinCount.value() == 0 {
                    strongSelf.updateLoadingUIStatus()
                }
            }
        }
        if shouldSpin{
            self.loadingSpinCount.increment()
            if self.loadingSpinCount.value() == 1 {
                self.updateLoadingUIStatus()
            }
        }
        
    }
    public func downloadJSON(url: URLConvertible, shouldSpin: Bool=true, completionJSONHandler: @escaping  (DataResponse<Any>) -> Void)
    {
        self.downloadSessionManager.request(url).validate().responseJSON { [weak self] (result) in
            guard let strongSelf = self else {return}
            completionJSONHandler(result)
            if shouldSpin {
                strongSelf.loadingSpinCount.decrement()
                if strongSelf.loadingSpinCount.value() == 0 {
                    strongSelf.updateLoadingUIStatus()
                }
            }
        }
        if shouldSpin{
            self.loadingSpinCount.increment()
            if self.loadingSpinCount.value() == 1 {
                self.updateLoadingUIStatus()
            }
        }
    }
    public func downloadJSON(url: URLRequestConvertible, shouldSpin: Bool=true, completionJSONHandler: @escaping (DataResponse<Any>) -> Void)
    {
        self.downloadSessionManager.request(url).validate().responseJSON { [weak self] (result) in
            guard let strongSelf = self else {return}
            completionJSONHandler(result)
            if shouldSpin {
                strongSelf.loadingSpinCount.decrement()
                if strongSelf.loadingSpinCount.value() == 0 {
                    strongSelf.updateLoadingUIStatus()
                }
            }
        }
        if shouldSpin{
            self.loadingSpinCount.increment()
            if self.loadingSpinCount.value() == 1 {
                self.updateLoadingUIStatus()
            }
        }
    }

}
