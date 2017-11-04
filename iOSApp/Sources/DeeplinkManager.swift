//
//  DeeplinkManager.swift
//  eduDemo
//
//  Created by Alan Zhang on 2/15/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

// Note: the following showViewContoller has assumption
//   1) One ViewController type corresponds to one place only in either TabBarController of NavigationController
//      If the same ViewController is used in multiple Tabs in TabBarController, it only goes to the first one
//        Each Tab can have NavigationController
//   2) It assume each parameter correspond to a stored property in ViewController
//      If

import Foundation
import UIKit
class DeepLinkConfig
{
    var logging: Bool? = false
    var storyboards : [String:Any]?
    var routes : [String:Any]?
    var defaultRoute : [String:Any]?
    
    static let LOGGING_JSON_NAME = "logging"
    static let ROUTES_JSON_NAME = "routes"
    static let STORYBOARD_JSON_NAME = "storyboard"
    static let DEFAULT_ROUTE_JSON_NAME = "defaultRoute"
    init(fileName:String)
    {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    self.logging = jsonResult[DeepLinkConfig.LOGGING_JSON_NAME] as? Bool
                    self.storyboards = jsonResult[DeepLinkConfig.STORYBOARD_JSON_NAME] as? [String:Any]
                    self.routes = jsonResult[DeepLinkConfig.ROUTES_JSON_NAME] as? [String:Any]
                    self.defaultRoute = jsonResult[DeepLinkConfig.DEFAULT_ROUTE_JSON_NAME] as? [String:Any]
                } catch {
                    NSLog("Invalid JSON format for Deeplink config file \(fileName)")
                }
            } catch {
                NSLog("Unable to load Deeplink config file \(fileName)")
            }
        }

    }
}

class DeepLinkManager
{
    static let STORYBOARD_IPHONE_NAME = "iPhone"
    static let STORYBOARD_IPAD_NAME = "iPad"
    static let CLASS_JSON_NAME = "class"
    static let HANDLERS_JSON_NAME = "handler"
    static let IDENTIFIER_JSON_NAME = "identifier"
    static let ROUTE_PARAMS_JSON_NAME = "routeParameters"
    static let REQUIRED_JSON_NAME = "required"
    static let REGEX_JSON_NAME = "regex"
    static let STORYBOARD_JSON_NAME = "storyboard"

    static var sharedInstance : DeepLinkManager = DeepLinkManager()
    var rootViewController : UIViewController? = nil
    
    var config : DeepLinkConfig?
    
    private init(){ // Prevents others from using the default () initializer
        rootViewController = UIApplication.shared.keyWindow?.rootViewController
    }
    class func test()
    {
//        DeepLinkManager.sharedInstance.routeURL(URL.init(string: "quanTech://CourseList")!)
        DeepLinkManager.sharedInstance.routeURL(URL.init(string: "quanTech://CourseList/1?x=2&y=3&z&classURL=http%3A%2F%2Fwww.google.com")!)
    }
    open func loadConfig(_ fileName: String)
    {
        self.config = DeepLinkConfig.init(fileName: fileName)
    }
    open func routeURL(_ url: URL) -> Bool
    {
        // First: run adapters
//        if (url.host == nil) || url.path.lengthOfBytes(using: .utf8)==0 || url.path == "/" {
        if (url.host == nil) {
            NSLog("Route to default view controller")
            self.routeToDefault()
            return true
        }
        let (routeOptions, routeParams) = self.searchDeepLinkRoutes(url)
        
        if (routeOptions == nil){
            self.routeToDefault()
        }else{
            // Then: displayView
            self.displayView(routeOptions!, routeParams: routeParams)
        }
        return true
    }
    open func routeToDefault()
    {
        self.displayView((config?.defaultRoute)!, routeParams: nil)
    }
    open func displayView(_ routeOptions : [String:Any], routeParams : [String:Any]? )
    {
        guard let viewController = self.buildViewController(routeOptions) else{
            if (config?.logging)! {
                NSLog("Unable to find view controller for \(routeOptions.description)")
            }
            return
        }
        if (routeParams != nil){
            let isPropertySet = self.setPropertiesOnViewController(viewController, routeParams: routeParams!, routeOptions: routeOptions)
            if(!isPropertySet){
                if(config?.logging == true){
                    NSLog("Unable to set properties for view controller: \(routeParams!.description)")
                }
                return
            }
        }
        self.showViewController(viewController)
    }
    private func containedInArray(_ viewController:UIViewController, controllerArray:[UIViewController]) -> Bool
    {
        for controller in controllerArray {
            if (type(of:controller) === type(of:viewController)){
                return true
            }
        }
        return false
    }
    
    open func showViewController(_ viewController : UIViewController) -> Void
    {
        if self.rootViewController == nil {
            self.rootViewController = UIApplication.shared.keyWindow?.rootViewController
        }
        if let tabController = self.rootViewController as? UITabBarController{
            for vcInTab : UIViewController in tabController.viewControllers! {
                if type(of:vcInTab) === type(of:viewController) {
                    tabController.selectedViewController = vcInTab
                    if(config?.logging == true){
                        NSLog("Present in tab of TabBarController")
                    }
                    return
                }
                if let navController = vcInTab as? UINavigationController {
                    if self.containedInArray(viewController, controllerArray: navController.viewControllers) {
                        tabController.selectedViewController = vcInTab
                        self.pushViewControllerOntoRoot(navController, vc: viewController)
                        return
                    }
                }
            }
            // Otherwise, just display it in Tab 0, if it is a navigationController
            if let navController = tabController.viewControllers?[0] as? UINavigationController {
                self.pushViewControllerOntoRoot(navController, vc: viewController)
                tabController.selectedIndex = 0
                if(config?.logging == true){
                    NSLog("Present on top of NavController within TabBarController")
                }
                return
            }
            assert(false, "Unhandled view controller in DeeplinkManager")
            return
        }
        if let navController = self.rootViewController as?  UINavigationController {
            self.pushViewControllerOntoRoot(navController, vc: viewController)
            if(config?.logging == true){
                NSLog("Present on top of NavigationController")
            }
            return
        }
        // Last resort.  Just remove everything, display this
        if(config?.logging == true){
            NSLog("Present as Root in Application")
        }
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    open func pushViewControllerOntoRoot(_ navController: UINavigationController, vc : UIViewController)
    {
        // TODO: probably just pushViewController, instead of replace the existing ViewControllers.
        //
        navController.setViewControllers([vc], animated: false)
        
//        navController.popToRootViewController(animated: false)
//        if ( type(of:vc) === type(of: navController.viewControllers[0])  ) {
//            navController.pushViewController(vc, animated: true)
//        }
    }
    open func buildViewController(_ routerOptions: [String:Any]) -> UIViewController?
    {
        var viewController : UIViewController?
        var storyboardName : String?
        if self.config?.storyboards != nil {
            storyboardName = self.getStoryboardName((self.config?.storyboards)!)
        }
        if routerOptions[DeepLinkManager.STORYBOARD_JSON_NAME] != nil {
            storyboardName = self.getStoryboardName(routerOptions[DeepLinkManager.STORYBOARD_JSON_NAME] as! [String:Any])
        }
        let identifier = routerOptions[DeepLinkManager.IDENTIFIER_JSON_NAME] as? String
        let className = routerOptions[DeepLinkManager.CLASS_JSON_NAME] as? String
        if (storyboardName != nil), (identifier != nil) { // Try storyboard first
            let storyboard = UIStoryboard.init(name: storyboardName!, bundle: nil)
            viewController = storyboard.instantiateViewController(withIdentifier: identifier!);
            if(config?.logging == true && viewController != nil ){
                NSLog("Found view controller in storyboard \(storyboardName)")
            }
        }else if (className != nil), (identifier != nil) { // Try Nib files
            viewController = Bundle.main.loadNibNamed(className!, owner: self, options: nil)?[0] as? UIViewController
            if(config?.logging == true && viewController != nil){
                NSLog("Found view controller in Nib file \(className)")
            }
        }else if (className != nil) { // Try the class itself
            let uiclass = NSClassFromString(className!) as? UIViewController.Type
            viewController = uiclass?.init()
            if(config?.logging == true && viewController != nil){
                NSLog("Found view controller in class with name\(className)")
            }
        }
        return viewController
    }
    public func getStoryboardName(_ storyboard: [String:Any]) -> String?
    {
//        "storyboard": {
//            "iPhone" : "Main_iPhone",
//            "iPad" : "Main_iPad"
//        },
        var storyboardName : String?
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            storyboardName = storyboard[DeepLinkManager.STORYBOARD_IPHONE_NAME] as! String?
        }else{
            storyboardName = storyboard[DeepLinkManager.STORYBOARD_IPAD_NAME] as! String?
            if storyboardName == nil {
                storyboardName = storyboard[DeepLinkManager.STORYBOARD_IPHONE_NAME] as! String?
            }
        }
        return storyboardName
    }
    public func setPropertiesOnViewController(_ viewController:UIViewController, routeParams: [String:Any], routeOptions:[String:Any]?) -> Bool
    {
//        let vcClassName = type(of:viewController).description()
        let vcClassName = viewController.classForCoder.description()
        let requiredParameters = self.getRequiredParameters(routeOptions)
        for (paramKey, paramValue) in routeParams {

            // Validation follows pattern described here: https://developer.apple.com/library/mac/documentation/cocoa/conceptual/KeyValueCoding/Articles/Validation.html
            // User can create custom validators for their properties. If none exist, validateValue will return YES by default.
            do{
                var ioValue : AnyObject? = paramValue as AnyObject?
                let hasProperty = viewController.responds(to: Selector(paramKey))
//                try viewController.validateValue(&ioValue, forKey: paramKey)
                if hasProperty {
                     try viewController.setValue(paramValue, forKey: paramKey)
                }else{
                    if(config?.logging == true){
                        NSLog("Unable setting value: \(paramValue) on key: \(paramKey) for \(vcClassName)")
                    }
                    if(requiredParameters != nil && (requiredParameters?.contains(paramKey) == true) ){
                        return false
                    }
                }
            }catch{
                if(config?.logging == true){
                    NSLog("Unable to set property \(paramValue) on : \(paramKey) for \(vcClassName)")
                }
                return false
            }
        }
        return true
    }
    public func searchDeepLinkRoutes(_ url : URL) -> ([String:Any]?, [String:Any]?)
    {
        guard let allRoutes = self.config?.routes  as? [String:AnyObject] else {
            NSLog("No routes is configured")
            return (nil, nil)
        }
        for (routePath, routeOptions) in allRoutes {
            // First check path
            let routeOptions = routeOptions as? [String:Any]
            var (valid, pathParams) = self.matchDeepLinkPath(url, routePath: routePath, routeOptions:routeOptions)
            if(valid){
                //Then check query parameters
                let urlComponents = url.query?.components(separatedBy: "&")
                if( urlComponents != nil ){
                    if (pathParams == nil){
                        pathParams = [String:String]()
                    }
                    for queryItem in urlComponents! {
                        let keyvaluePair = queryItem.components(separatedBy: "=")
                        if keyvaluePair.count == 2 {
                            let validParam = self.validateRouteComponent(keyvaluePair[0], value: keyvaluePair[1], routeOptions: routeOptions)
                            if(validParam){
                                pathParams?[keyvaluePair[0]] = (keyvaluePair[1] as String).removingPercentEncoding
                            }

                        }
                    }
                }
                // Finally, check required parameters
                if self.checkRequiredParameters(pathParams, routeOptions: routeOptions) {
                    return (routeOptions, pathParams)
                }else{
                    return (nil, nil)
                }
            }
        }
        return (nil, nil)
    }
    open func matchDeepLinkPath(_ url:URL, routePath: String, routeOptions:[String:Any]?) -> (Bool, [String:Any]?)
    {
// http://foobar:nicate@example.com:8080/some/path/file.html;params-here?foo=bar#baz
//        -[NSURL scheme] = http
//        -[NSURL resourceSpecifier] = (everything from // to the end of the URL)
//            -[NSURL user] = foobar
//            -[NSURL password] = nicate
//            -[NSURL host] = example.com
//            -[NSURL port] = 8080
//            -[NSURL path] = /some/path/file.html
//            -[NSURL pathComponents] = @["/", "some", "path", "file.html"] (note that the initial / is part of it)
//        -[NSURL lastPathComponent] = file.html
//        -[NSURL pathExtension] = html
//        -[NSURL parameterString] = params-here
//        -[NSURL query] = foo=bar
//        -[NSURL fragment] = baz
        
        if url.host == nil {
            return (false, nil)
        }
        var routeComponents = routePath.components(separatedBy: "/");
        if (url.host != routeComponents[0] ){ // HostName not match
            return (false, nil)
        }
        if( url.pathComponents.count == 0 ){
            // No path is specified.
            if  let requiredParameters = self.getRequiredParameters(routeOptions), requiredParameters.count != 0 {
                return(false, nil)
            }
            return (true, nil)
        }
        if (url.pathComponents.count != routeComponents.count ){
            return (false, nil)
        }
        var params : [String:Any]? = [String:Any]()
        for i in 1 ..< url.pathComponents.count {
            if(url.pathComponents[i] != routeComponents[i]){
                if (routeComponents[i].hasPrefix(":")){ // It is a placeholder
                    var routeComponentName = routeComponents[i]
                    routeComponentName.remove(at: routeComponentName.startIndex)
                    // Both followings will work
//                    routeComponentName = routeComponentName.substring(from: routeComponentName.index(after: routeComponentName.startIndex))
//                    routeComponentName = routeComponentName.substring(with: routeComponentName.index(routeComponentName.startIndex, offsetBy: 1) ..< routeComponentName.endIndex)
                    let validate = self.validateRouteComponent(routeComponentName, value: url.pathComponents[i], routeOptions: routeOptions)
                    if validate {
                        params?[routeComponentName] = url.pathComponents[i]
                    }else{
                        NSLog("Invalid value \(url.pathComponents[i]) for parameter \(routeComponentName)")
                        return (false, nil)
                    }
                }else{
                    return (false, nil)
                }
            }
        }
        return (true, params)
    }
    public func validateRouteComponent(_ name:String, value: String, routeOptions:[String:Any]?) -> Bool
    {
//        "routeParameters": {
//            "dataId": {
//                "required": "true",
//                "regex": "[0-9]"
//            },
//            "utmSource": {
//                "required": "false"
//            }
//        }
        let routeParameters = routeOptions?[DeepLinkManager.ROUTE_PARAMS_JSON_NAME] as? [String:Any]
        let pathComponentParameters = routeParameters?[name] as? [String:Any]
        if let regexString = pathComponentParameters?[DeepLinkManager.REGEX_JSON_NAME] as? String {
            do {
                let regex = try NSRegularExpression.init(pattern: regexString, options: NSRegularExpression.Options(rawValue: 0))
                let result = regex.matches(in: value, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange.init(location: 0, length: value.lengthOfBytes(using: .utf8)))
                
                return result.count == 1
            }catch {
                NSLog("Invalid regex for parameter \(name) in routeOptions: \(routeOptions.debugDescription)")
            }
        }
        return true
    }
    public func checkRequiredParameters(_ params:[String:Any]?, routeOptions:[String:Any]?) -> Bool
    {
//        "routeParameters": {
//            "utmSource": {
//                "required": "false"
//            }
//        }
        guard let requiredParameters = self.getRequiredParameters(routeOptions) else{
            return true
        }
        for requiredParam in requiredParameters {
            if(params?[requiredParam] == nil){
                return false
            }
        }
        return true
    }
    public func getRequiredParameters(_ routeOptions:[String:Any]?) -> [String]?
    {
        //        "routeParameters": {
        //            "utmSource": {
        //                "required": "false"
        //            }
        //        }
        let parameters = routeOptions?[DeepLinkManager.ROUTE_PARAMS_JSON_NAME] as? [String:Any]
        if(parameters == nil){
            return nil
        }
        var requiredParameters  = [String]()
        for (paramItem, paramAttr) in parameters! {
            let paramAttr = paramAttr as? [String:Any]
            if let required = paramAttr?[DeepLinkManager.REQUIRED_JSON_NAME] as? Bool, required==true {
                requiredParameters.append(paramItem)
            }else if paramAttr?[DeepLinkManager.REQUIRED_JSON_NAME] as? String == "true" {
                requiredParameters.append(paramItem)
            }
        }
        return requiredParameters
    }
}

