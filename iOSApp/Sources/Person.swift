//
//  Person.swift
//  eduDemo
//
//  Created by Alan Zhang on 12/6/16.
//  Copyright © 2016 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
class Person
{
    var firstName : String?
    var lastName : String?
    var fullName : String?
    var age : Int?
    var systemId : String?
    var profession : String?
    var classRoom : String?
    var school : String?
    var region : String?
    
    var selfDescription: String?
    
    var personIcon : UIImage?
    var wechatNo : String?
    var cellphone : String?
    var qqNo : String?
    var email : String?
    
    required init(){
        firstName = ""
        lastName = ""
        systemId = "No ID"
    }
    convenience init(firstname:String, lastname:String, sysId:String){
        self.init()
        firstName = firstname
        lastName = lastname
        systemId = sysId
    }
}
