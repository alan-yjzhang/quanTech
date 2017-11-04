//
//  SMSAPI.swift
//  quanTech
//
//  Created by Alan Zhang on 10/28/17.
//  Copyright © 2017 AlanZhang. All rights reserved.
//

import Foundation
import SwiftyXMLParser
let kSMSAPIErrorDomain = "SMSAPIErrorDomain"
let kSMSAPIErrorTitle = "SMSAPIErrorTitle"
let kSMSAPIErrorMessage = "SMSAPIErrorMessage"
let kUserDefaultsLoginID  = "UserDefaultsLoginID"
let kUserDefaultsPassword = "UserDefaultsPassword"

typealias  SMSResponseHandler = (_ result: Any?, _ error: Error?) -> Void
class SMSAPI : NSObject
{
    static var  serverAddr : String? = "http://orangeoak"
    static var  APIPath : String? = "/SMSportal/XPage.aspx?"
    static var  sessionID : String?
    static var  userProfile : Person?
    
    static var serverUrl : String? {
        get{
            if serverAddr != nil {
                return serverAddr! + APIPath!
            }
            return nil
        }
    }
    static var  sharedSMSAPI = SMSAPI()
    
    override init() {
        super.init()
        let userDefaults = UserDefaults.standard
        if let loginID = userDefaults.object(forKey: kUserDefaultsLoginID) {
            self.loginAccount = loginID as! String
        }
        if let loginPass = userDefaults.object(forKey: kUserDefaultsPassword){
            self.loginPassword = loginPass as! String
        }
    }
    
    var loginAccount : String? {
        didSet{
            UserDefaults.standard.set(loginAccount, forKey: kUserDefaultsLoginID)
        }
    }
    var loginPassword : String? {
        didSet{
            UserDefaults.standard.set(loginPassword, forKey: kUserDefaultsPassword)
        }
    }
    class func  isLoggedIn() -> Bool {
        return SMSAPI.sessionID != nil && !(SMSAPI.sessionID!.isEmpty)
    }
    func queryString(queryParams : [String:String?]) -> String?{
        var result : [String]? = []
        for (key,value) in queryParams {
            if value != nil {
                let encodedValue = value!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                result?.append(key + "=" + encodedValue!)
            }else{
                result?.append(key)
            }
            
        }
        return result?.joined(separator: "&")
    }
    func login(_ accountID: String, password: String?, completion: SMSResponseHandler?)
    {
        //Module=Login&XMLType=Login&Mode=Save&LOGINUSERNAME=teacher123&LOGINPASSWORD=123456&APITYPE=mobile
        let params = ["Module":"Login",
                      "XMLType": "Login",
                      "Mode" : "Save",
                      "APITYPE" : "mobile",
                      "LOGINUSERNAME": accountID,
                      "LOGINPASSWORD": password,
        ]
        let urlString = SMSAPI.serverUrl! + queryString(queryParams: params)!
        var request : URLRequest = URLRequest.init(url: URL.init(string: urlString)!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.addValue("application/xml", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        let body = self.queryString(queryParams: params)?.data(using:.utf8)
//        request.httpBody = body
//        request.setValue("Content-Length", forHTTPHeaderField: String(describing: body?.count) )
        let dataTask = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            guard error == nil else{
                print("Network error" + error!.localizedDescription)
                completion?(nil, error)
                return
            }
            let xmlResponse = try! XML.parse(data!)
            // First, check if there is ERROR node in response
            let hit = xmlResponse["PAGE", "ERRORS"]
            if case .failure( _) = hit  {
                // Then, check if there is SESSIONID in the response
                if case .failure(_) =  xmlResponse["PAGE", "REQUESTINFO", "SESSIONID"] {
                    print("Unable to find any SESSIONID in the response")
                    completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle: "Server Error",kSMSAPIErrorMessage:"Unable to get SESSIONID"]))
                    return
                }
                SMSAPI.sessionID = xmlResponse["PAGE", "REQUESTINFO", "SESSIONID"].text
                self.loginAccount = accountID
                self.loginPassword = password
                completion?(self, nil)
                return
            }
            // Then, This is the ERROR message from server
            let errorNode = xmlResponse["PAGE", "ERRORS", "ERROR", 0]
            var errorMsg : String
            if case .failure( _) = errorNode {
                errorMsg = "Internal error"
            }else{
                errorMsg = errorNode.text!
            }
            completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle:"Login Error", kSMSAPIErrorMessage:errorMsg]))
        }
        dataTask.resume()
    }
    func getUserProfile(_ completion: SMSResponseHandler?)
    {
        //Module=SysAdmin&XMLType=PortalUserPreferences&Mode=Edit&APITYPE=mobile&SessionID=3qkfUeCo2XjKw2vd5v%2fSYoVhRtJMtoKMGHFwJ35CPdE%3d&Password=1
        let params = ["Module":"SysAdmin",
                      "XMLType": "PortalUserPreferences",
                      "Mode" : "Edit",
                      "APITYPE" : "mobile",
                      "Password": loginPassword!,
                      ]
        let urlString = SMSAPI.serverUrl! + queryString(queryParams: params)! + "&SessionID=" + SMSAPI.sessionID!
        var request : URLRequest = URLRequest.init(url: URL.init(string: urlString)!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.addValue("application/xml", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        //        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //        let body = self.queryString(queryParams: params)?.data(using:.utf8)
        //        request.httpBody = body
        //        request.setValue("Content-Length", forHTTPHeaderField: String(describing: body?.count) )
        let dataTask = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            guard error == nil else{
                print("Network error" + error!.localizedDescription)
                completion?(nil, error)
                return
            }
            let xmlResponse = try! XML.parse(data!)
            // First, check if there is ERROR node in response
            let hit = xmlResponse["PAGE", "ERRORS"]
            if case .failure( _) = hit  {
                // Then, check if there is USER in the response
                if case .failure(_) =  xmlResponse["PAGE", "DATA", "USER"] {
                    print("Unable to find any USER info in the response")
                    completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle: "Server Error",kSMSAPIErrorMessage:"Unable to get USER profile"]))
                    return
                }
                let userInfo = xmlResponse["PAGE", "DATA", "USER"]
                let userProfile = Person()
                userProfile.systemId = userInfo["IUSERID"].text
                userProfile.cellphone = userInfo["VCPHONE"].text
                userProfile.lastName = userInfo["VCLASTNAME"].text
                userProfile.firstName = userInfo["VCFIRSTNAME"].text
                userProfile.email = userInfo["VCEMAILADDRESS1"].text
                userProfile.school = userInfo["SCHOOLS","SCHOOL",0,"VCDISPLAYSCHOOLNAME"].text
                userProfile.selfDescription = userInfo["VCROLEDESCRIPTION"].text ?? ""
                userProfile.selfDescription = userProfile.selfDescription! + " Email:\(userProfile.email ?? "")"
                SMSAPI.userProfile = userProfile
                completion?(userProfile, nil)
                return
            }
            // Then, This is the ERROR message from server
            let errorNode = xmlResponse["PAGE", "ERRORS", "ERROR", 0]
            var errorMsg : String
            if case .failure( _) = errorNode {
                errorMsg = "Internal error"
            }else{
                errorMsg = errorNode.text!
            }
            completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle:"User Profile Error", kSMSAPIErrorMessage:errorMsg]))
        }
        dataTask.resume()
    }
    class func testXMLData() {
        if  let filePath = Bundle.main.path(forResource: "testData1", ofType: "xml") {
            do {
                let contentData = try NSData.init(contentsOfFile: filePath, options: NSData.ReadingOptions.mappedIfSafe) as Data
                let sessionID : String?
                //                do{
                let xmlResponse = try! XML.parse(contentData)
                let hit = xmlResponse["PAGE", "ERRORS"]
                if case .failure(let error) = hit  { // No Error is found
                    if case .failure(let error) =  xmlResponse["PAGE", "REQUESTINFO", "SESSIONID"] {
                        print(error)
                        return
                    }
                    sessionID = xmlResponse["PAGE", "REQUESTINFO", "SESSIONID"].text
                    return
                }
                let errorNode = xmlResponse["PAGE", "ERRORS", "ERROR", 0]
                var errorMsg : String
                if case .failure(let _) = errorNode {
                    errorMsg = "Internal error"
                }else{
                    errorMsg = errorNode.text!
                }
                
                //                }catch{
                //                    assert(false, "Fatal error: invalid XML format for testData.json")
                //                }
                
            }catch{
                assert(false, "testData1.xml file read failed")
            }
        }
    }
    
}

