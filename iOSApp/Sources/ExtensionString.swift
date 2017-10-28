//
//  ExtensionString.swift
//  eduDemo
//
//  Created by Alan Zhang on 2/23/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation

extension String
{
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func contains(s: String) -> Bool {
        return self.range(of:s) != nil ? true : false
    }
    
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: .literal, range: nil)
    }
    
    subscript (i: Int) -> Character {
        get {
            let index = self.index(self.startIndex, offsetBy: i)
            return self[index]
        }
    }
    
    subscript (r: CountableClosedRange<Int>) -> String {
        get {
            let start = self.index(self.startIndex, offsetBy: r.lowerBound)
            let end = self.index(self.startIndex, offsetBy: r.upperBound)
            return self.substring(with: start..<end)
        }
    }
    func trim() -> String
    {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    func subString(startIndex: Int, length: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.index(self.startIndex, offsetBy: startIndex + length)
        return self.substring(with: start..<end)
    }
    func indexOf(target:String) -> Int{
        return self.indexOf(target: target, startIdx: 0)
    }
    func indexOf(target: String, startIdx: Int) -> Int {
        let startRange = self.index(self.startIndex, offsetBy: startIdx)
        
        let range = self.range(of:target, options: .literal, range: startRange ..< self.endIndex)
        
        if let range = range {
            return self.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(target: String) -> Int {
        var index = -1
        var stepIndex = self.indexOf(target: target)
        while stepIndex > -1 {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target: target, startIdx: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    
    func isMatch(regex: String, options: NSRegularExpression.Options) -> Bool {
        var exp:NSRegularExpression?
        
        do {
            exp = try NSRegularExpression(pattern: regex, options: options)
            
        } catch let error as NSError {
            exp = nil
            print(error.description)
            return false
        }
        
        let matchCount = exp!.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.length))
        return matchCount > 0
    }
    
    func getMatches(regex: String, options: NSRegularExpression.Options) -> [NSTextCheckingResult] {
        var exp:NSRegularExpression?
        
        do {
            exp = try NSRegularExpression(pattern: regex, options: options)
        } catch let error as NSError {
            print(error.description)
            exp = nil
            return []
        }
        
        let matches = exp!.matches(in: self, options: [], range: NSMakeRange(0, self.length))
        return matches
    }
    
    private var vowels: [String] {
        get {
            return ["a", "e", "i", "o", "u"]
        }
    }
    
    private var consonants: [String] {
        get {
            return ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"]
        }
    }
    
    func pluralize(count: Int) -> String {
        if count == 1 {
            return self
        } else {
            let lastChar = self.subString(startIndex: self.length - 1, length: 1)
            let secondToLastChar = self.subString(startIndex: self.length - 2, length: 1)
            var prefix = "", suffix = ""
            
            if lastChar.lowercased() == "y" && vowels.filter({x in x == secondToLastChar}).count == 0 {
                prefix = self[0...self.length-1]
                suffix = "ies"
            } else if lastChar.lowercased() == "s" || (lastChar.lowercased() == "o" && consonants.filter({x in x == secondToLastChar}).count > 0) {
                prefix = self[0...self.length]
                suffix = "es"
            } else {
                prefix = self[0...self.length]
                suffix = "s"
            }
            
            return prefix + (lastChar != lastChar.uppercased() ? suffix : suffix.uppercased())
        }
    }
    static func test(){
        guard "Awesome".contains("me") else{
            assert(false, "test failed")
            return
        }
        let test1 =  "ReplaceMe".replace(target: "Me", withString: "You")
        let test2 =  "MeReplace".replace(target: "Me", withString: "You")
        guard   "0123456789"[0] == "0", "0123456789"[5] == "5" , "0123456789"[5...6] == "5"  else{
            assert(false, "test failed")
            return
        }
        guard "Hello, playground"[0...5] == "Hello", "Coolness"[4...7] == "nes" else{
            assert(false, "test failed")
            return
        }
        let idx1 =  "Awesome".indexOf(target:"nothin")
        
        guard "Awesome".indexOf(target:"some") == 3, "Awesome".indexOf(target:"e", startIdx: 3) == 6, "Awesome".lastIndexOf(target:"e") == 6 else{
            assert(false, "test failed")
            return
        }
        var emailRegex = "[a-z_\\-\\.]+@[a-z_\\-\\.]{3,}"
        guard "email@test.com".isMatch(regex: emailRegex, options: .caseInsensitive),  "email-test.com".isMatch(regex: emailRegex, options: .caseInsensitive) == false else{
            assert(false, "test failed")
            return
        }
        
        var testText = "email@test.com, other@test.com, yet-another@test.com"
        var matches = testText.getMatches(regex: emailRegex, options: .caseInsensitive)
        guard matches.count == 3 else{
            assert(false, "test failed")
            return
        }
        guard   testText.subString(startIndex: matches[0].range.location, length: matches[0].range.length) == "email@test.com",
            testText.subString(startIndex: matches[1].range.location, length: matches[1].range.length) == "other@test.com",
            testText.subString(startIndex: matches[2].range.location, length: matches[2].range.length) == "yet-another@test.com" else{
                assert(false, "test failed")
                return
        }
        guard  "Reply".pluralize(count: 0) == "Replies",
        "Reply".pluralize(count: 1) == "Reply",
        "Reply".pluralize(count: 2) == "Replies",
        "REPLY".pluralize(count: 3) == "REPLIES",
        "Horse".pluralize(count: 2) == "Horses",
        "Boy".pluralize(count: 2) == "Boys",
        "Cut".pluralize(count: 2) == "Cuts",
        "Boss".pluralize(count: 2) == "Bosses",
            "Domino".pluralize(count: 2) == "Dominoes" else{
                assert(false, "test failed")
                return
        }
    }
}
//"Awesome".contains("me") == true
//"Awesome".contains("Aw") == true
//"Awesome".contains("so") == true
//"Awesome".contains("Dude") == false
//
//"ReplaceMe".replace("Me", withString: "You") == "ReplaceYou"
//"MeReplace".replace("Me", withString: "You") == "YouReplace"
//"ReplaceMeNow".replace("Me", withString: "You") == "ReplaceYouNow"
//
//"0123456789"[0] == "0"
//"0123456789"[5] == "5"
//"0123456789"[9] == "9"
//
//"0123456789"[5...6] == "5"
//"0123456789"[0...1] == "0"
//"0123456789"[8...9] == "8"
//"0123456789"[1...5] == "1234"
//"Reply"[0...4] == "Repl"
//"Hello, playground"[0...5] == "Hello"
//"Coolness"[4...7] == "nes"
//
//"Awesome".indexOf("nothin") == -1
//"Awesome".indexOf("Awe") == 0
//"Awesome".indexOf("some") == 3
//"Awesome".indexOf("e", startIndex: 3) == 6
//"Awesome".lastIndexOf("e") == 6
//"Cool".lastIndexOf("o") == 2
//
//var emailRegex = "[a-z_\\-\\.]+@[a-z_\\-\\.]{3,}"
//"email@test.com".isMatch(emailRegex, options: NSRegularExpressionOptions.CaseInsensitive) == true
//"email-test.com".isMatch(emailRegex, options: NSRegularExpressionOptions.CaseInsensitive) == false
//
//var testText = "email@test.com, other@test.com, yet-another@test.com"
//var matches = testText.getMatches(emailRegex, options: NSRegularExpressionOptions.CaseInsensitive)
//matches.count == 3
//testText.subString(matches[0].range.location, length: matches[0].range.length) == "email@test.com"
//testText.subString(matches[1].range.location, length: matches[1].range.length) == "other@test.com"
//testText.subString(matches[2].range.location, length: matches[2].range.length) == "yet-another@test.com"
//
//"Reply".pluralize(0) == "Replies"
//"Reply".pluralize(1) == "Reply"
//"Reply".pluralize(2) == "Replies"
//"REPLY".pluralize(3) == "REPLIES"
//"Horse".pluralize(2) == "Horses"
//"Boy".pluralize(2) == "Boys"
//"Cut".pluralize(2) == "Cuts"
//"Boss".pluralize(2) == "Bosses"
//"Domino".pluralize(2) == "Dominoes"
