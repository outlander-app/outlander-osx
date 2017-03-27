//
//  AttributeTokenizer.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

open class AttributesTokenizer {
    
    struct Attribute {
        var name:String
        var value:String
    }
    
    open func tokenize(_ data:String) -> [String:String]{
        var attributes = [String:String]()
        
        let context = ParseContext(atPosition:0, withMarker:data.startIndex, forString:data)
        while !context.complete {
            if let attr = self.scanAttribute(context) {
                attributes[attr.name] = attr.value
            }
        }
        
        return attributes
    }
    
    fileprivate func scanAttribute(_ context:ParseContext) -> Attribute?{
        context.advanceTo { (char) -> Bool in
            return char == "="
        }
        
        if context.complete {
            return nil
        }
        
        let name = context.consumedCharacters.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        context.advance()
        context.flushConsumedCharacters()
        
        context.advance()
        
        let match:Character = context.consumedCharacters[0]
        context.flushConsumedCharacters()
        
        context.advanceTo { (char) -> Bool in
            return char == match
        }
        
        let value = context.consumedCharacters
        context.flushConsumedCharacters()
        context.advance()
        context.flushConsumedCharacters()
        
        return Attribute(name: name, value: value)
    }
}
