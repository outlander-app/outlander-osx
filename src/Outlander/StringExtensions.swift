//
//  StringExtensions.swift
//  Parser
//
//  Created by Joseph McBride on 3/20/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension String {

    func contains(_ find: String) -> Bool {
        return self.range(of: find) != nil
    }

    func containsIgnoringCase(_ find: String) -> Bool {
        return self.range(of: find, options: .caseInsensitive) != nil
    }

    func containsAny(_ list: [String]) -> Bool {
        for item in list {
            if self.contains(item) {
                return true
            }
        }

        return false
    }

    public func trimEnd(_ set:CharacterSet) -> String {

        var count = 0

        for char in self.characters.reversed() {

            if !set.contains(char.unicodeScalar) {
                break
            }
            
            count = count + 1
        }
    
        return self.substring(from: 0, to: self.characters.count - count)
    }
    
    public func trim(_ type:String) -> String {
        let newVal = self.trimPrefix(type)
        return newVal.trimSuffix(type)
    }
    
    public func trimPrefix(_ prefix:String) -> String {
        
        if(self.hasPrefix(prefix)) {
            return self.substring(from: self.characters.index(self.startIndex, offsetBy: prefix.characters.count))
        }
        
        return self
    }
    
    public func trimSuffix(_ suffix:String) -> String {
        
        if(self.hasSuffix(suffix)) {
            return self.substring(with: self.startIndex ..< self.characters.index(self.endIndex, offsetBy: -1*suffix.characters.count))
        }
        
        return self
    }
    
    public func replace(_ target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
//    subscript (i: Int) -> String {
//        return String(self[i] as Character)
//    }

//    subscript (r: Range<Int>) -> String {
//        return substring(with: characters.index(startIndex, offsetBy: r.lowerBound) ..< characters.index(startIndex, offsetBy: r.upperBound))
//    }

    subscript (r: Range<String.Index>) -> String {
        return substring(with: r)
    }
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathComponent(path)
    }
    
    func toBool() -> Bool? {
        let trueValues = ["true", "yes", "1", "on", "+"]
        let falseValues = ["false", "no", "0", "off", "-"]
        
        let lowerSelf = self.lowercased()
        
        if trueValues.contains(lowerSelf) {
            return true
        }
        
        if falseValues.contains(lowerSelf) {
            return false
        }
        
        return nil
    }

    func substringFromIndex(_ index:Int) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: index))
    }

    func splitToCommands() -> [String] {

        var results:[String] = []

        let matches = self["((?<!\\\\);)"].matchResults()

        var lastIndex = 0
        let length = self.characters.count

        for match in matches {
            let matchLength = match.range.location - lastIndex
            let start = self.characters.index(self.startIndex, offsetBy: lastIndex)
            let end = self.characters.index(start, offsetBy: matchLength)
            var str = self.substring(with: start..<end)
            str = str.replacingOccurrences(of: "\\;", with: ";")
            results.append(str)

            lastIndex = match.range.location + match.range.length
        }

        if lastIndex < length {
            let start = self.characters.index(self.startIndex, offsetBy: lastIndex)
            let end = self.characters.index(start, offsetBy: length - lastIndex)
            var str = self.substring(with: start ..< end)
            str = str.replacingOccurrences(of: "\\;", with: ";")
            results.append(str)
        }
        
        return results
    }
}
