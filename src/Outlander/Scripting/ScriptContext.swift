//
//  ScriptContext.swift
//  Scripter
//
//  Created by Joseph McBride on 11/17/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

import Foundation
import OysterKit

public class Stack<T>
{
    var stack:[T] = []
    
    public func push(item:T) {
        stack.append(item)
    }
    
    public func pop() -> T {
        return stack.removeLast()
    }
    
    public func lastItem() -> T? {
        return stack.last
    }
    
    public func hasItems() -> Bool {
        return stack.count > 0
    }
}

public struct GosubContext {
    var label:LabelToken
    var labelIndex:Int
    var returnLine:Int
    var returnIndex:Int
    var params:[String]
    var vars:[String:String]
    var isGosub:Bool
}

public class ScriptContext {
    var tree:[Token]
    var marker:TokenSequence
    var results:Array<Token>
    var current:GeneratorOf<Token>
    var gosubContext:GosubContext?
    var gosubStack:Stack<GosubContext>
    
    private let varReplacer:SimpleVarReplacer
    private var variables:[String:String] = [:]
    private var params:[String]
    private var paramVars:[String:String] = [:]
    
    private var globalVars:(()->[String:String])?
    
    init(_ tree:[Token], globalVars:(()->[String:String])?, params:[String]) {
        self.tree = tree
        self.marker = TokenSequence()
        self.marker.tree = self.tree
        self.current = self.marker.generate()
        self.results = Array<Token>()
        self.varReplacer = SimpleVarReplacer()
        self.globalVars = globalVars
        self.gosubStack = Stack<GosubContext>()
       
        self.params = params
        self.updateParamVars()
    }
    
    public func shiftParamVars() -> Bool {
        var res = false
        
        if let first = self.params.first {
            self.params.removeAtIndex(0)
            self.updateParamVars()
            res = true
        }
        
        return res
    }
    
    private func updateParamVars() {
        self.paramVars = [:]
        
        var all = ""
        
        for param in self.params {
            if param.rangeOfString(" ") != nil {
                all += " \"\(param)\""
            } else {
                all += " \(param)"
            }
        }
        
        self.paramVars["0"] = all.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        for (index, param) in enumerate(self.params) {
            self.paramVars["\(index+1)"] = param
        }
    }
    
    public func varsForDisplay() -> [String] {
        var vars:[String] = []
        
        for (key, value) in self.paramVars {
            vars.append("\(key): \(value)")
        }
        
        for (key, value) in self.variables {
            vars.append("\(key): \(value)")
        }
        
        return vars
    }
    
    public func execute() {
//        seq.currentIdx = 1
        
        for t in marker {
            evalToken(t)
        }
    }
    
    public func setVariable(identifier:String, value:String) {
        self.variables[identifier] = value
    }
    
    public func gotoLabel(label:String, params:[String], previousLine:Int, isGosub:Bool = false) -> Bool {
        var returnIdx = self.marker.currentIdx
        self.marker.currentIdx = -1
        var found = false
        
        var trimmed = label.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString
        
        while let token = self.current.next() {
            if let labelToken = token as? LabelToken where labelToken.characters.lowercaseString == trimmed {
                found = true
                
                if params.count > 0 || isGosub {
                    
                    var gosub = GosubContext(
                        label: labelToken,
                        labelIndex: self.marker.currentIdx,
                        returnLine: previousLine,
                        returnIndex:returnIdx,
                        params: params,
                        vars: [:],
                        isGosub: isGosub)
                    
                    for (index, param) in enumerate(params) {
                        gosub.vars["\(index)"] = param
                    }
                    
                    if isGosub && self.gosubContext != nil && self.gosubContext!.isGosub {
                        self.gosubStack.push(self.gosubContext!)
                    }
                    
                    self.gosubContext = gosub
                    
                    if isGosub {
                        self.gosubStack.push(gosub)
                    }
                }
                
                break
            }
        }
        
        self.marker.currentIdx -= 1
        return found
    }
    
    public func popGosub() -> GosubContext? {
        if self.gosubStack.hasItems() {
            var last = self.gosubStack.pop()
            self.marker.currentIdx = last.returnIndex
            self.gosubContext = self.gosubStack.lastItem()
            return last
        }
        return nil
    }
    
    public func roundtime() -> Double? {
        return self.globalVars?()["roundtime"]?.toDouble()
    }
    
    public func next() -> Token? {
        var nextToken = self.current.next()
        
        if let token = nextToken {
            evalToken(token)
        }
        
        return nextToken
    }
    
    public func evalToken(token:Token) {
        if(token is BranchToken) {
            var branchToken = token as! BranchToken
            if(!evalIf(branchToken)) {
                self.marker.branchStack.pop()
            }
        }

        if !(token.name == "whitespace") {
            self.results.append(token)
        }
    }
    
    private func evalIf(token:BranchToken) -> Bool {
        if let count = token.argumentCheck {
            let result = self.params.count >= count
            token.lastResult = "\(self.params.count) >= \(count) = \(result)"
            return result
        }
        
        var evaluator = ExpressionEvaluator()
        var (result, info) = evaluator.eval(token.expression, self.simplify)
        token.lastResult = info
        return result
    }
    
    public func simplify(data:String) -> String {
        var text = data
        
        if let gosub = self.gosubContext where gosub.vars.count > 0 && text.hasPrefix("$") {
            text = varReplacer.eval(text, vars: gosub.vars)
        }
        
        if text.hasPrefix("%") {
            text = varReplacer.eval(text, vars: self.variables)
            if text.hasPrefix("%") {
                text = varReplacer.eval(text, vars: self.paramVars)
            }
        }
        
        if text.hasPrefix("$") && self.globalVars != nil {
            text = varReplacer.eval(text, vars: self.globalVars!())
        }
        
        return text
    }
    
    public func simplify(tokens:Array<Token>) -> String {
        var text = ""
        
        for t in tokens {
            text += t.characters
        }
        
        return self.simplify(text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
    }
    
    public func simplifyEach(tokens:Array<Token>) -> String {
        var result = ""
        
        for t in tokens {
            if t is WhiteSpaceToken {
                result += t.characters
            }
            else {
                result += self.simplify(t.characters)
            }
        }
        
        return result
    }
}

class TokenSequence : SequenceType {
    var tree:[Token]
    var currentIdx:Int
    var branchStack:Stack<GeneratorOf<Token>>
    
    init () {
        currentIdx = -1
        tree = [Token]()
        branchStack = Stack<GeneratorOf<Token>>()
    }
    
    func generate() -> GeneratorOf<Token> {
        return GeneratorOf<Token>({
            if var b = self.branchStack.lastItem() {
                if let next = b.next() {
                    return next
                } else {
                    self.branchStack.pop()
                }
            }
            
            var bodyToken = self.getNext()
            if let nextToken = bodyToken {
                if let branchToken = nextToken as? BranchToken {
                    var seq = BranchTokenSequence(branchToken).generate()
                    self.branchStack.push(seq)
                }
                return nextToken
            } else {
                return .None
            }
        })
    }
    
    func getNext() -> Token? {
        var token:Token?
        self.currentIdx++
        if(self.currentIdx > -1 && self.currentIdx < self.tree.count) {
            token = self.tree[self.currentIdx]
        }
        
        if let next = token {
            if next.name == "whitespace" {
                token = getNext()
            }
        }
        
        return token
    }
}

class BranchTokenSequence : SequenceType {
    var token:BranchToken
    var branchStack:Stack<GeneratorOf<Token>>
    var currentIndex:Int
    
    init (_ token:BranchToken) {
        self.token = token
        currentIndex = -1
        branchStack = Stack<GeneratorOf<Token>>()
    }
    
    func generate() -> GeneratorOf<Token> {
        return GeneratorOf<Token>({
            if var b = self.branchStack.lastItem() {
                if let next = b.next() {
                    return next
                } else {
                    self.branchStack.pop()
                }
            }
            
            var bodyToken = self.getNext()
            if let nextToken = bodyToken {
                if let branchToken = nextToken as? BranchToken {
                    var seq = BranchTokenSequence(branchToken).generate()
                    self.branchStack.push(seq)
                    return branchToken
                }
                
                return nextToken
            } else {
                return .None
            }
        })
    }
    
    func getNext() -> Token? {
        var token:Token?
        self.currentIndex++
        if(self.currentIndex < self.token.body.count) {
            token = self.token.body[self.currentIndex]
        }
        
        if let next = token as? WhiteSpaceToken {
            token = getNext()
        }
        
        return token
    }
}
