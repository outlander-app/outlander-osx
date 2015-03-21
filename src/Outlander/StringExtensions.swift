//
//  StringExtensions.swift
//  Parser
//
//  Created by Joseph McBride on 3/20/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

extension String {
    public func trim(type:String) -> String {
        var newVal = self.trimPrefix(type)
        return newVal.trimSuffix(type)
    }
    
    public func trimPrefix(prefix:String) -> String {
        
        if(self.hasPrefix(prefix)) {
            return self.substringFromIndex(advance(self.startIndex, countElements(prefix)))
        }
        
        return self
    }
    
    public func trimSuffix(suffix:String) -> String {
        
        if(self.hasSuffix(suffix)) {
            return self.substringWithRange(Range<String.Index>(start:self.startIndex, end:advance(self.endIndex, -1*countElements(suffix))))
        }
        
        return self
    }
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
    
    subscript (r: Range<String.Index>) -> String {
        return substringWithRange(r)
    }
}
