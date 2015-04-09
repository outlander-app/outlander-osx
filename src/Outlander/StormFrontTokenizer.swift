//
//  StormFrontTokenizer.swift
//  Parser
//
//  Created by Joseph McBride on 3/20/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

@objc protocol TokenRecieverDelegate {
    func didRecieveToken(token:Node)
}

@objc public class ParseContext : Printable {
    var nodes = [Node]()
    var consumedCharacters : String {
        let substring = __sourceString[__startIndex..<__currentIndex]
        return substring
    }
    
    private let __sourceString : String
    let sourceLength:Int
    
    var current : Character
    var next : Character?
    let eot : Character = "\u{04}"
    
    var scanAdvanced = false
    
    private var __marker : String.Generator {
        didSet {
            scanAdvanced = true
        }
    }
    
    var complete : Bool {
        return current == eot
    }
    
    private var __startIndex : String.Index
    private var __currentIndex : String.Index
    
    var startPosition : Int
    var currentPosition : Int
    
    var tagName:String
    var value:String?
    var attributes:[String:String]?
    
    public init(atPosition:Int, withMarker:String.Index, forString:String){
        __startIndex = withMarker
        __currentIndex = __startIndex
        __sourceString = forString
        sourceLength = count(__sourceString)
        
        current = eot
        
        __marker = __sourceString.generate()
        if let first = __marker.next() {
            current = first
            next = __marker.next()
        }
        
        startPosition = atPosition
        currentPosition = atPosition
        
        tagName = ""
    }
    
    func flushConsumedCharacters(){
        __startIndex = __currentIndex
        startPosition = currentPosition
    }
    
    func createNode(_ children:[Node]? = nil) {
        let node = Node(tagName.lowercaseString, value, attributes)
        
        if let c = children {
            node.children = c
        }
        
        nodes.append(node)
        
        tagName = ""
        value = nil
        attributes = nil
    }
    
    //
    // Moves forward in the supplied string
    //
    public func advance(){
        if next != nil {
            current = next!
            next = __marker.next()
        } else {
            current = eot
        }
        
        if(!complete) {
            __currentIndex++
            currentPosition++
        }
    }
    
    public func advanceTo(match:(Character)->Bool) {
        while !complete {
            if match(current) {
                return
            }
            advance()
        }
    }
    
    public func advanceToIndex(index:String.Index) {
        while(!complete && __currentIndex < index) {
            advance()
            //println("(\(complete)) adanceToIdx: \(index)  cur=\(__currentIndex)")
        }
    }
    
    public var description : String {
        return "Started at: \(startPosition), now at: \(currentPosition), having consumed \(consumedCharacters) and holding \(nodes)"
    }
}

@objc public class StormFrontTokenizer : NSObject {
    
    class func newInstance() -> StormFrontTokenizer {
        return StormFrontTokenizer()
    }
    
    private let attrTokenizer = AttributesTokenizer()
    
    private var  __contextStack = [ParseContext]()
    
    override init(){
        super.init()
    }
    
    public func tokenize(input:String) -> [Node] {
        
        let context = ParseContext(atPosition: 0, withMarker:input.startIndex, forString:input)
        
        var nodes = scanContext(context)
        nodes.append(Node("eot"))
        
        return nodes
    }
    
    private func scanContext(ctx:ParseContext) -> [Node] {
        while !ctx.complete {
            scanTag(ctx)
        }
        return ctx.nodes
    }
    
    private func pushContext(context:ParseContext, range:Range<String.Index>) -> [Node] {
        let newStr = context.__sourceString[range]
        let newContext = ParseContext(atPosition: 0, withMarker:newStr.startIndex, forString:newStr)
        return scanContext(newContext)
    }
    
    private func scanTag(context:ParseContext) {
        
        if context.startPosition == context.currentPosition
            && context.currentPosition == context.sourceLength - 1
            && context.current !=  "\r\n" {
            let length = context.sourceLength - 1
            let data = context.__sourceString.substringFromIndex(advance(context.__sourceString.startIndex, length))
            let token = Node("text", data, nil)
            context.nodes.append(token)
            context.advance()
            return
        }
        
        if context.current != "<" {
            context.advanceTo({ (char:Character) -> Bool in
                return char == "<"
            })
            
            if count(context.consumedCharacters) > 0 {
                let token = Node("text", context.consumedCharacters, nil)
                context.nodes.append(token)
            }
        }
        
        context.advance()
        context.flushConsumedCharacters()
        context.advanceTo { (char:Character) -> Bool in
            return char == " " || char == ">" || (char == "/" && context.next == ">")
        }
        context.tagName = context.consumedCharacters
        context.flushConsumedCharacters()
        
        if context.current == "/" && context.next == ">" {
            // self closing tag
            context.createNode()
            context.advance()
            context.advance()
            context.flushConsumedCharacters()
            return
        }
        
        if context.current != ">" {
            context.advanceTo({ (char:Character) -> Bool in
                return char == ">" || (char == "/" && context.next == ">")
            })
            context.attributes = attrTokenizer.tokenize(context.consumedCharacters)
            
            if context.current == "/" && context.next == ">" {
                // self closing tag
                context.createNode()
                context.advance()
                context.advance()
                context.flushConsumedCharacters()
                return
            }
        }
        
        if context.complete {
            return
        }
        
        // consume '>' char
        context.advance()
        context.flushConsumedCharacters()
        
        context.advanceTo { (char:Character) -> Bool in
            return char == "<"
        }
        
        if context.complete {
            return
        }
        
        if context.next != "/" && context.next != context.tagName[0] {
            // new tag
            //println("\n\n****new tag!****\n")
            let checker = "</\(context.tagName)>"
            let endRange = context.__sourceString.rangeOfString(checker)
            let childNodes = pushContext(context, range: Range(start: context.__startIndex, end: endRange!.startIndex))
            context.createNode(childNodes)
            
            // advance to end of closing tag
            context.advanceToIndex(endRange!.endIndex)
            context.flushConsumedCharacters()
            return
        }
        
        context.value = context.consumedCharacters
        context.flushConsumedCharacters()
        context.advanceTo { (char:Character) -> Bool in
            return char == ">"
        }
        context.createNode()
        
        // consume '>' char
        context.advance()
        context.flushConsumedCharacters()
    }
}
