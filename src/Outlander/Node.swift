//
//  Node.swift
//  Parser
//
//  Created by Joseph McBride on 3/20/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

@objc
open class Node : NSObject {
    var name:String
    var value:String?
    var attributes:[String: String]? {
        didSet {
            if !_isTrimming {
                trimAttributes()
            }
        }
    }
    var children:[Node]
    
    init(_ name:String) {
        self.name = name
        children = []
    }
    
    convenience init(_ name:String, _ value:String?, _ attributes:[String:String]?) {
        self.init(name)
        self.value = value
        self.attributes = attributes
        
        trimAttributes()
    }
    
    fileprivate var _isTrimming = false
    
    open func hasAttr(_ key:String) -> Bool {
        if let dict = self.attributes {
            return dict.index(forKey: key) != nil
        }
        
        return false
    }
    
    open func attr(_ key:String) -> String? {
        if hasAttr(key) {
            return self.attributes?[key]
        }
        
        return nil
    }
    
    override open var description : String {
        return "Node name=\(name) value=\(value) attrs=\(attributes)"
    }
    
    fileprivate func trimAttributes() {
        
        if self.attributes == nil {
            return
        }
        
        _isTrimming = true
        
        for (key,val) in self.attributes! {
            var newVal = val.trim("\"")
            newVal = newVal.trim("\'")
            self.attributes![key] = newVal
        }
        
        _isTrimming = false
    }
}
