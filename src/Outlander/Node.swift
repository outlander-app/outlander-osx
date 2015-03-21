//
//  Node.swift
//  Parser
//
//  Created by Joseph McBride on 3/20/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

@objc public class Node {
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
    
    private var _isTrimming = false
    
    public func hasAttr(key:String) -> Bool {
        if let dict = self.attributes {
            return dict.indexForKey(key) != nil
        }
        
        return false
    }
    
    public func attr(key:String) -> String? {
        return self.attributes?[key]
    }
    
    public var description : String {
        return "Node name=\(name) value=\(value) attrs=\(attributes)"
    }
    
    private func trimAttributes() {
        
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
