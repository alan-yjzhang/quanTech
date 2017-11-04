//
//  LoginViewController.swift
//  quanTechTests
//
//  Created by Alan Zhang on 10/28/17.
//  Copyright © 2017 AlanZhang. All rights reserved.
//

import Foundation
import UIKit

let kUserDefaultsUserAccount = "UserAccount"
let kUserDefaultsUserPassword = "UserPassword"
let kUserDefaultsServerAddr = "ServerAddress"
class LoginViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var userAccount: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var serverAddr: UITextField!
    
    private var savedUserAccount : String? {
        get{
            if let value = UserDefaults.standard.object(forKey: kUserDefaultsUserAccount) {
                return value as? String
            }
            return nil
        }
        set{
            UserDefaults.standard.set(newValue, forKey: kUserDefaultsUserAccount)
        }
    }
    private var savedUserPassword : String? {
        get{
            if let value = UserDefaults.standard.object(forKey: kUserDefaultsUserPassword) {
                return value as? String
            }
            return nil
        }
        set{
            UserDefaults.standard.set(newValue, forKey: kUserDefaultsUserPassword)
        }
    }
    private var savedServerAddr : String? {
        get{
            if let value = UserDefaults.standard.object(forKey: kUserDefaultsServerAddr) {
                return value as? String
            }
            return nil
        }
        set{
            UserDefaults.standard.set(newValue, forKey: kUserDefaultsServerAddr)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userAccount.delegate = self
        self.password.delegate = self
        self.serverAddr.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userAccount.text = self.savedUserAccount
        self.password.text = self.savedUserPassword
        self.serverAddr.text = self.savedServerAddr
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.userAccount.resignFirstResponder()
        self.password.resignFirstResponder()
        self.serverAddr.resignFirstResponder()
        
        self.savedUserAccount = self.userAccount.text
        self.savedUserPassword = self.password.text
        if serverAddr.text?.isEmpty == false {
            self.savedServerAddr = serverAddr.text
            SMSAPI.serverAddr = serverAddr.text
        }
        SMSAPI.sharedSMSAPI.login(self.savedUserAccount!, password: self.savedUserPassword!) { (result, error) in
            DispatchQueue.main.async {
                guard error == nil else{
                    let alert = UIAlertController(title: "系统错误", message: "无法登录 \(self.savedUserAccount)  服务器 \(SMSAPI.serverAddr)", preferredStyle: .alert)
                    let OKAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
                        // stay until user login
                    })
                    alert.addAction(OKAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let alert = UIAlertController(title: "登录成功", message: "欢迎你使用本系统！", preferredStyle: .alert)
                let OKAction = UIAlertAction.init(title: "继续", style: .default, handler: { (action) in
                    SMSAPI.sharedSMSAPI.getUserProfile({ (profile, error) in
                        guard error == nil else {
                            print("Failed to get user profile")
                            return
                        }
                        DispatchQueue.main.async {
//                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                            appDelegate.mainTabViewController?.selectedIndex = 1
                            DeepLinkManager.sharedInstance.routeURL(URL.init(string: "quanTech://CourseList")!)
                        }
                    })
                })
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
