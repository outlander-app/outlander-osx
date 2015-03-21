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

@objc public class StormFrontTokenizer : NSObject {
    
    class func newInstance() -> StormFrontTokenizer {
        return StormFrontTokenizer()
    }
    
    private class Context : Printable {
        var nodes = [Node]()
        var consumedCharacters : String {
            let substring = __sourceString[__startIndex..<__currentIndex]
            
            return substring
        }
        
        private let __sourceString : String
        
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
        
        private init(atPosition:Int, withMarker:String.Index, forString:String){
            __startIndex = withMarker
            __currentIndex = __startIndex
            __sourceString = forString
            
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
        
        internal func flushConsumedCharacters(){
            __startIndex = __currentIndex
            startPosition = currentPosition
        }
        
        internal func createNode(_ children:[Node]? = nil) {
            let node = Node(tagName, value, attributes)
            
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
                advance()
                if match(current) {
                    return
                }
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
    
    private var __tokenHandler : (Node)->Bool
    private var  __contextStack = [Context]()
    
    override init(){
        __tokenHandler = {(token:Node)->Bool in
            println("No token handler specified")
            return false
        }
        
        super.init()
    }
    
    public func tokenize(input:String, tokenReceiver : (Node)->(Bool)) {
        
        __tokenHandler = tokenReceiver
        
        let context = Context(atPosition: 0, withMarker:input.startIndex, forString:input)
        
        let nodes = scanContext(context)
        
        for node in nodes {
            __tokenHandler(node)
        }
        
        __tokenHandler(Node("eot"))
    }
    
    private func scanContext(ctx:Context) -> [Node] {
        while !ctx.complete {
            println("scanning", ctx.description)
            scanTag(ctx)
        }
        return ctx.nodes
    }
    
    private func pushContext(context:Context, range:Range<String.Index>) -> [Node] {
        let newStr = context.__sourceString[range]
        let newContext = Context(atPosition: 0, withMarker:newStr.startIndex, forString:newStr)
        return scanContext(newContext)
    }
    
    private func scanTag(context:Context) {
        
        if context.current != "<" {
            context.advanceTo({ (char:Character) -> Bool in
                return char == "<"
            })
            
            if countElements(context.consumedCharacters) > 0 {
                let token = Node("text", context.consumedCharacters, nil)
                context.nodes.append(token)
            }
        }
        println(context.description)
        context.advance()
        context.flushConsumedCharacters()
        context.advanceTo { (char:Character) -> Bool in
            return char == " " || char == ">" || (char == "/" && context.next == ">")
        }
        context.tagName = context.consumedCharacters
        println(context.description)
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
            println(context.description)
            context.attributes = context.consumedCharacters["(\\w+)=('[^']*'|[^\n]*)"].dictionary()
            
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
        println(context.description)
        
        if context.complete {
            return
        }
        
        if context.next != "/" && context.next != context.tagName[0] {
            // new tag
            println("\n\n****new tag!****\n")
            //pushContext()
            let checker = "</\(context.tagName)>"
            let endRange = context.__sourceString.rangeOfString(checker)
            println("checker=\(checker) range=\(endRange)\n\n")
            let childNodes = pushContext(context, range: Range(start: context.__startIndex, end: endRange!.startIndex))
            println(context.description)
            println("children!", childNodes)
            context.createNode(childNodes)
            
            // advance to end of closing tag
            context.advanceToIndex(endRange!.endIndex)
            
            println(context.description)
            
            context.flushConsumedCharacters()
            
            println(context.description)
            
            return
        }
        
        context.value = context.consumedCharacters
        context.flushConsumedCharacters()
        context.advanceTo { (char:Character) -> Bool in
            return char == ">"
        }
        println(context.description)
        context.createNode()
        
        // consume '>' char
        context.advance()
        context.flushConsumedCharacters()
    }
}
