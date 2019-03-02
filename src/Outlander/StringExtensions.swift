//
//  StringExtensions.swift
//  Parser
//
//  Created by Joseph McBride on 3/20/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension String {
    public func trim(type:String) -> String {
        let newVal = self.trimPrefix(type)
        return newVal.trimSuffix(type)
    }
    
    public func trimPrefix(prefix:String) -> String {
        
        if(self.hasPrefix(prefix)) {
            return self.substringFromIndex(self.startIndex.advancedBy(prefix.characters.count))
        }
        
        return self
    }

    public func trimSuffix(suffix:String) -> String {
        
        if(self.hasSuffix(suffix)) {
            return self.substringWithRange(self.startIndex ..< self.endIndex.advancedBy(-1*suffix.characters.count))
        }
        
        return self
    }
    
    public func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(startIndex.advancedBy(r.startIndex) ..< startIndex.advancedBy(r.endIndex))
    }
    
    subscript (r: Range<String.Index>) -> String {
        return substringWithRange(r)
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathComponent(path)
    }
    
    func toBool() -> Bool? {
        let trueValues = ["true", "yes", "1", "on", "+"]
        let falseValues = ["false", "no", "0", "off", "-"]
        
        let lowerSelf = self.lowercaseString
        
        if trueValues.contains(lowerSelf) {
            return true
        }
        
        if falseValues.contains(lowerSelf) {
            return false
        }
        
        return nil
    }
}
