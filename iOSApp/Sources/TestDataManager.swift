//
//  TestDataManager.swift
//  eduDemo
//
//  Created by Alan Zhang on 4/11/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
class TestDataManager : NSObject
{
    static let testFilename = "testData"
    static let sharedManager = TestDataManager()
    
    var personInfo:[String:Any]?=nil
    var homePage : [String: Any]? = nil
    var courseList : [Any]? = nil
    var classActivity: [Any]? = nil
    var scoreList:[Any]? = nil
    var menuList:[Any]? = nil
    
    var person : Person? = nil
    
    override init() {
        if  let filePath = Bundle.main.path(forResource: TestDataManager.testFilename, ofType: "json") {
            do {
                let contentData = try NSData.init(contentsOfFile: filePath, options: NSData.ReadingOptions.mappedIfSafe) as Data
                do{
                    let jsonResult = try JSONSerialization.jsonObject(with: contentData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    self.personInfo = jsonResult["Person"] as? [String:Any]
                    self.homePage = jsonResult["HomePage"] as? [String:Any]
                    self.courseList = jsonResult["CourseList"] as? [Any]
                    self.classActivity = jsonResult["ClassActivity"] as? [Any]
                    self.scoreList = jsonResult["ScoreList"] as? [Any]
                    self.menuList = jsonResult["MenuList"] as? [Any]
                    if let personInfo = self.personInfo {
                        self.person = Person()
                        self.person?.systemId = personInfo["SystemId"] as? String
                        self.person?.firstName = personInfo["Name"] as? String
                        self.person?.school  = personInfo["School"] as? String
                        self.person?.classRoom = personInfo["ClassNo"] as? String
                        self.person?.region = personInfo["Region"] as? String
                        self.person?.profession = personInfo["Profession"] as? String
                        self.person?.wechatNo = personInfo["WeChat"] as? String
                        self.person?.qqNo = personInfo["QQ"] as? String
                        self.person?.cellphone = personInfo["CellPhone"] as? String
                        self.person?.email = personInfo["Email"] as? String
                        self.person?.selfDescription = personInfo["SelfDescription"] as? String
                        if let imageName = personInfo["Image"] as? String {
                            self.person?.personIcon = UIImage.init(named: imageName)
                        }
                    }

                }catch{
                    assert(false, "Fatal error: invalid JSON format for testData.json")
                }
                
            }catch{
                assert(false, "testData.json file read failed")
            }
        }
    }
    
}
