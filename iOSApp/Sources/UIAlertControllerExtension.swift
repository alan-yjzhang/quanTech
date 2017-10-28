//
//  UIAlertControllerExtension.swift
//  eduDemo
//
//  Created by Alan Zhang on 12/9/16.
//  Copyright © 2016 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit

//  Forward note:
/*   Scenario: The user taps on a button on a view controller. The view controller is the topmost (obviously) in the navigation stack. 
    The tap invokes a utility class method called on another class. A bad thing happens there and I want to display an alert right there before control returns to the view controller.
  Question:  how do you present a UIAlertController, right there in myUtilityMethod?
 
 Solution 1: DBAlertController
    Answer from Apple Engineer:
     Internally Apple is creating a UIWindow with a transparent UIViewController and then presenting the UIAlertController on it. Basically what is the following Dylan Betterman's answer.
    Usage:
        DBAlertController.show(animated:true, nil)
 
 Solution 2: use following extension
    Condition: the root view controller must be in the view hierachy.
    Otherwise, it does not work.
    Usage: 
        //option 1:
        myAlertController.show()
        //option 2:
        myAlertController.present(animated: true) {

 
 Solution 3:
    let alertController = UIAlertController(title: "title", message: "message", preferredStyle: .Alert)
    //...
    var rootViewController = UIApplication.shared.keyWindow?.rootViewController
    if let navigationController = rootViewController as? UINavigationController {
        rootViewController = navigationController.viewControllers.first
    }
    if let tabBarController = rootViewController as? UITabBarController {
        rootViewController = tabBarController.selectedViewController
    }
    rootViewController?.present(alertController, animated: true, completion: nil)
*/
public extension UIAlertController {
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else {
            if  let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion)
            }
        }
    }
}

public class DBAlertController: UIAlertController {
    //
    //  DBAlertController.swift
    //  DBAlertController
    //
    //  Created by Dylan Bettermann on 5/11/15.
    //  Copyright (c) 2015 Dylan Bettermann. All rights reserved.
    //
    /// The UIWindow that will be at the top of the window hierarchy. The DBAlertController instance is presented on the rootViewController of this window.
    private lazy var alertWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = DBClearViewController()
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindowLevelAlert
        return window
    }()
    
    /**
     Present the DBAlertController on top of the visible UIViewController.
     
     - parameter flag:       Pass true to animate the presentation; otherwise, pass false. The presentation is animated by default.
     - parameter completion: The closure to execute after the presentation finishes.
     */
    public func show(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if let rootViewController = alertWindow.rootViewController {
            
            alertWindow.makeKeyAndVisible()
            
            rootViewController.present(self, animated: flag, completion: completion)
        }
    }
    
}

// In the case of view controller-based status bar style, make sure we use the same style for our view controller
private class DBClearViewController: UIViewController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        get {
            return UIApplication.shared.statusBarStyle
        }
    }
    override var prefersStatusBarHidden : Bool {
        get{
            return UIApplication.shared.isStatusBarHidden
        }
    }
}

