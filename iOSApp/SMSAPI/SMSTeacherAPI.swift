//
//  SMSTeacherAPI.swift
//  quanTech
//
//  Created by Alan Zhang on 11/1/17.
//  Copyright © 2017 AlanZhang. All rights reserved.
//

import Foundation
import SwiftyXMLParser
class SMSAPITeacher: SMSAPI {
    
    static var sharedSMSTeacherAPI = SMSAPITeacher()
    
    func getClassList(_ completion: SMSResponseHandler?)
    {
        //Module=Teacher&XMLType=TeacherStudent&Mode=Display&APITYPE=mobile&SessionID=3qkfUeCo2XjKw2vd5v%2fSYoVhRtJMtoKMGHFwJ35CPdE%3d
        let params = ["Module":"Teacher",
                      "XMLType": "TeacherStudent",
                      "Mode" : "Display",
                      "APITYPE" : "mobile",
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
                if case .failure(_) =  xmlResponse["PAGE", "DATA", "CLASSES"] {
                    print("Unable to find any USER info in the response")
                    completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle: "Server Error",kSMSAPIErrorMessage:"Unable to get USER profile"]))
                    return
                }
                let classInfo = xmlResponse["PAGE", "DATA", "CLASSES"]
                completion?(classInfo, nil)
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
    func getStudentInfo(_ studentId:String, completion: SMSResponseHandler?)
    {
        let params = ["Module":"Teacher",
                      "XMLType": "TeacherStudent",
                      "Mode" : "Display",
                      "APITYPE" : "mobile",
                      "CourseId" : studentId,
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
                if case .failure(_) =  xmlResponse["PAGE", "DATA", "SELECTEDSTUDENT"] {
                    print("Unable to find any USER info in the response")
                    completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle: "Server Error",kSMSAPIErrorMessage:"Unable to get Student info"]))
                    return
                }
                let students = xmlResponse["PAGE", "DATA", "SELECTEDSTUDENT"]
                completion?(students, nil)
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
            completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle:"Student Error", kSMSAPIErrorMessage:errorMsg]))
        }
        dataTask.resume()
    }
    func getStudentList(_ courseId:String, section:String, scheduleId:String, completion: SMSResponseHandler?)
    {
        let params = ["Module":"Teacher",
                      "XMLType": "TeacherStudent",
                      "Mode" : "Display",
                      "APITYPE" : "mobile",
                      "CourseId" : courseId,
                      "VCCourseId" : courseId,
                      "VCSECTION" : section,
                      "ISCHEDULEID" : scheduleId
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
                if case .failure(_) =  xmlResponse["PAGE", "DATA", "STUDENTS"] {
                    print("Unable to find any USER info in the response")
                    completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle: "Server Error",kSMSAPIErrorMessage:"Unable to get Students list"]))
                    return
                }
                let students = xmlResponse["PAGE", "DATA", "STUDENTS"]
//                <STUDENT>
//                <CSTUDENTID>004572378</CSTUDENTID>
//                <VCASSUMEDLASTNAME>徐</VCASSUMEDLASTNAME>
//                <VCASSUMEDFIRSTNAME>亮</VCASSUMEDFIRSTNAME>
//                <CASSUMEDMIDDLEINITIAL />
//                    <ISTATUSCODE>0</ISTATUSCODE>
//                <CCURRENTGRADECODE>08       </CCURRENTGRADECODE>
//                <VCASSUMEDLASTNAME />
//                    <VCASSUMEDFIRSTNAME />
//                    </STUDENT>
                completion?(students, nil)
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
            completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle:"Student Error", kSMSAPIErrorMessage:errorMsg]))
        }
        dataTask.resume()
    }
    func getHomeworkList(_ courseId:String, section:String, scheduleId:String, completion: SMSResponseHandler?)
    {
        //Module=Teacher&XMLType=HomeWork&Mode=Edit&APITYPE=mobile&SessionID=xx%3d&CourseId=000052&VCCourseId=000052&VCSECTION=03&ISCHEDULEID=17316
        let params = ["Module":"Teacher",
                      "XMLType": "HomeWork",
                      "Mode" : "Edit",
                      "APITYPE" : "mobile",
                      "CourseId" : courseId,
                      "VCCourseId" : courseId,
                      "VCSECTION" : section,
                      "ISCHEDULEID" : scheduleId
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
                if case .failure(_) =  xmlResponse["PAGE", "DATA", "GRADEBOOKTASKS"] {
                    print("Unable to find any USER info in the response")
                    completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle: "Server Error",kSMSAPIErrorMessage:"Unable to get Homework list"]))
                    return
                }
                let homeworkInfo = xmlResponse["PAGE", "DATA", "GRADEBOOKTASKS"]
                completion?(homeworkInfo, nil)
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
            completion?(nil, NSError.init(domain: kSMSAPIErrorDomain, code: -1, userInfo: [kSMSAPIErrorTitle:"Homework list Error", kSMSAPIErrorMessage:errorMsg]))
        }
        dataTask.resume()
    }
    
}
