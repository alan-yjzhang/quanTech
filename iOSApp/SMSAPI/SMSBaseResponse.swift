//
//  SMSBaseResponse.swift
//  quanTech
//
//  Created by Alan Zhang on 10/28/17.
//  Copyright © 2017 AlanZhang. All rights reserved.
//

import Foundation
import SwiftyXMLParser
class SMSBaseResponse : NSObject
{
    
    
    class func testSwiftySMLParser() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let string = "<ResultSet><Result  id=\"x\"><Hit index=\"1\"><Name>Item1</Name></Hit><Hit index=\"2\"><Name>Item2</Name></Hit></Result></ResultSet>"
        let xml = try! XML.parse(string) // -> XML.Accessor
        
        //        let string = "<ResultSet><Result id=\"x\"><Hit index=\"1\"><Name>Item1</Name></Hit><Hit index=\"2\"><Name>Item2</Name></Hit></Result></ResultSet>"
        //        let data = string.dataUsingEncoding(NSUTF8StringEncoding)
        //        self.xml = XML.parse(data) // -> XML.Accessor
        
        if case .failure(let error) =  xml["ResultSet", "Result", "TypoKey"] {
            print(error)
        }
        // Access grandchild
        // option 1
        let element = xml["ResultSet"]["Result"] // -> <Result><Hit index=\"1\"><Name>Item1</Name></Hit><Hit index=\"2\"><Name>Item2</Name></Hit></Result>
        print(element)
        
        // option 2
        let path = ["ResultSet", "Result"]
        let element2 = xml[path] // -> <Result><Hit index=\"1\"><Name>Item1</Name></Hit><Hit index=\"2\"><Name>Item2</Name></Hit></Result>
        print(element2)
        // option 3
        let element3 = xml["ResultSet", "Result"] // -> <Result><Hit index=\"1\"><Name>Item1</Name></Hit><Hit index=\"2\"><Name>Item2</Name></Hit></Result>
        print(element3)
        // Access specific grandchild Element
        let element4 = xml["ResultSet", "Result", "Hit", 1] // -> <Hit index=\"2\"><Name>Item2</Name></Hit>
        print(element4)
        // access XML Text
        if let text = xml["ResultSet", "Result", "Hit", 0, "Name"].text {
            print("exsists path & text in XML Element: \(text)")
        }
        // access XML Attribute
        let attributes = xml["ResultSet", "Result"].attributes
        if let id = attributes["id"] {
            print("exsists path & an attribute in XML Element: \(id)")
        }
        
        let attributes2 = xml["ResultSet", "Result", "Hit", 0].attributes
        if let index = attributes2["index"] {
            print("exsists path & an attribute in XML Element: \(index)")
        }
        
        // enumerate child Elements in the parent Element
        for hit in xml["ResultSet", "Result", "Hit"] {
            print("enumarate existing XML Elements")
        }

    }
}
