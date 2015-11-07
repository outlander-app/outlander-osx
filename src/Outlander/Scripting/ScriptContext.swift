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
    
    public func count() -> Int {
        return stack.count
    }
    
    public func clear() {
        stack.removeAll(keepCapacity: true)
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
    var marker:TokenSequence
    var current:AnyGenerator<Token>
}

public class ScriptContext {
    var tree:[Token]
    var marker:TokenSequence
    var results:Array<Token>
    var current:AnyGenerator<Token>
    var gosubContext:GosubContext?
    var gosubStack:Stack<GosubContext>
    var actionVars:[String:String] = [:]
    
    private var lastTopIfResult = false
    private var lastToken:Token?
    
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
        
        for (index, param) in self.params.enumerate() {
            self.paramVars["\(index+1)"] = param
        }
        
        self.variables["argcount"] = "\(self.paramVars.count)"
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
    
    public func getVariable(identifier:String) -> String? {
        return self.variables[identifier]
    }
    
    public func setVariable(identifier:String, value:String) {
        self.variables[identifier] = value
    }
    
    public func removeVariable(identifier:String) {
        self.variables.removeValueForKey(identifier)
    }
    
    public func localVarsCopy() -> [String:String] {
        let copy = self.variables
        return copy
    }
    
    public func gotoLabel(label:String, params:[String], previousLine:Int, isGosub:Bool = false) -> Bool {
        
        if isGosub && label.lowercaseString == "clear" {
            
            self.gosubStack.clear()
            
            return true
        }
        
        let returnIdx = self.marker.currentIdx
        
        let seq = TokenSequence()
        seq.tree = self.tree
        let cur = seq.generate()
        
        var found = false
        
        let trimmed = label.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString
        
        while let token = cur.next() {
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
                        isGosub: isGosub,
                        marker: self.marker,
                        current: self.current)
                    
                    for (index, param) in params.enumerate() {
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
        
        seq.currentIdx -= 1
        
        if found {
            self.marker = seq
            self.current = cur
        }
        
        return found
    }
    
    public func popGosub() -> GosubContext? {
        if self.gosubStack.hasItems() {
            let last = self.gosubStack.pop()
            self.marker = last.marker
            self.current = last.current
            self.gosubContext = self.gosubStack.lastItem()
            return last
        }
        return nil
    }
    
    public func roundtime() -> Double? {
        return self.globalVars?()["roundtime"]?.toDouble()
    }
    
    public func next() -> Token? {
        let nextToken = self.current.next()
        
        if let token = nextToken {
            evalToken(token)
        }
        
        self.lastToken = nextToken
        return nextToken
    }
    
    public func evalToken(token:Token) {
        if(token is BranchToken) {
            let branchToken = token as! BranchToken
            if(!evalIf(branchToken)) {
                let last = self.marker.branchStack.lastItem()!
                if last.sequence.branchStack.hasItems() {
                    last.sequence.branchStack.pop()
                } else {
                    self.marker.branchStack.pop()
                }
            }
        }
        
        if token is EvalCommandToken {
           self.evalEvalCommand(token as! EvalCommandToken)
        }

        if !(token.name == "whitespace") {
            self.results.append(token)
        }
    }
    
    private func evalEvalCommand(token:EvalCommandToken) {
        let evaluator = ExpressionEvaluator()
        token.lastResult = evaluator.eval(token.expression, self.simplify)
    }
    
    private func evalIf(token:BranchToken) -> Bool {
        if let count = token.argumentCheck {
            let result = self.params.count >= count
            token.lastResult = ExpressionEvalResult(
                result:EvalResult.Boolean(val:result),
                info:"\(self.params.count) >= \(count) = \(result)",
                matchGroups: nil)
            return result
        }
        
        let lastBranchToken = self.lastToken as? BranchToken
        var lastBranchResult = false
        
        if let lastBToken = lastBranchToken {
            lastBranchResult = getBoolResult(lastBToken.lastResult?.result)
        }
        
        let evaluator = ExpressionEvaluator()
        
        if token.name == "if" && token.expression.count > 0 {
            let res = evaluator.eval(token.expression, self.simplify)
            token.lastResult = res
            lastTopIfResult = getBoolResult(res.result)
            return lastTopIfResult
        } else if token.name == "elseif" && !lastTopIfResult && lastBranchToken != nil && !lastBranchResult {
           
            if token.expression.count > 0 {
                let res = evaluator.eval(token.expression, self.simplify)
                token.lastResult = res
                return getBoolResult(res.result)
            }
            
            token.lastResult = ExpressionEvalResult(result:EvalResult.Boolean(val: true), info:"true", matchGroups:nil)
            return true
        }
       
        token.lastResult = ExpressionEvalResult(result:EvalResult.Boolean(val: false), info:"false", matchGroups:nil)
        return false
    }
    
    private func getBoolResult(result:EvalResult?) -> Bool {
        
        if result == nil {
            return false
        }
        
        switch(result!) {
        case .Boolean(let x):
            return x
        default:
            return false
        }
    }
    
    public func simplify(data:String) -> String {
        
        let mutable = RegexMutable(data)
        
        if self.actionVars.count > 0 && data.rangeOfString("$") != nil {
            self.replace("\\$", target: mutable, dict: self.actionVars)
        }
        
        if let gosub = self.gosubContext where gosub.vars.count > 0 && data.rangeOfString("$") != nil {
            
            self.replace("\\$", target: mutable, dict: gosub.vars)
        }
        
        if data.rangeOfString("%") != nil {
            
            self.replace("%", target: mutable, dict: self.variables)
            self.replace("%", target: mutable, dict: self.paramVars)
        }
        
        if data.rangeOfString("$") != nil && self.globalVars != nil {
            
            self.replace("\\$", target: mutable, dict: self.globalVars!())
        }
        
        return String(mutable)
    }
    
    private func replace(prefix:String, target:NSMutableString, dict:[String:String]) {
        
        for key in dict.keys {
            target["\(prefix)\(key)"] ~= dict[key] ?? ""
        }
    }
    
    public func simplify(tokens:Array<Token>) -> String {
        var text = ""
        
        for t in tokens {
            
            if t.name == "quoted-string" {
                let res = self.simplify(t.characters)
                text += "\"\(res)\""
            }
            else if let idx = t as? IndexerToken {
                
                let replaced = self.simplify(idx.variable)
               
                var options = replaced.componentsSeparatedByString("|")
                let indexer = Int(self.simplify(idx.indexer)) ?? -1
                if indexer > -1 && options.count > indexer {
                    text += options[indexer]
                } else {
                    text += replaced
                }
                
            } else {
                text += t.characters
            }
        }
        
        return self.simplify(text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
    }
    
    public func simplifyEach(tokens:Array<Token>) -> String {
        var result = ""
        
        for t in tokens {
            if t is WhiteSpaceToken {
                result += t.characters
            }
            else if t.name == "quoted-string" {
                let res = self.simplify(t.characters)
                result += "\"\(res)\""
            }
            else if let idx = t as? IndexerToken {
                
                let replaced = self.simplify(idx.variable)
               
                var options = replaced.componentsSeparatedByString("|")
                let indexer = Int(self.simplify(idx.indexer)) ?? -1
                if indexer > -1 && options.count > indexer {
                    result += options[indexer]
                } else {
                    result += replaced
                }
                
            } else {
                result += self.simplify(t.characters)
            }
        }
        
        return result
    }
}

struct BranchContext {
    var sequence:BranchTokenSequence
    var generator:AnyGenerator<Token>
}

class TokenSequence : SequenceType {
    var tree:[Token]
    var currentIdx:Int
    var branchStack:Stack<BranchContext>
    
    init () {
        currentIdx = -1
        tree = [Token]()
        branchStack = Stack<BranchContext>()
    }
    
    func generate() -> AnyGenerator<Token> {
        return anyGenerator({
            if let b = self.branchStack.lastItem() {
                if let next = b.generator.next() {
                    return next
                } else {
                    self.branchStack.pop()
                }
            }
            
            let bodyToken = self.getNext()
            if let nextToken = bodyToken {
                if let branchToken = nextToken as? BranchToken {
                    let seq = BranchTokenSequence(branchToken)
                    let generator = seq.generate()
                    self.branchStack.push(BranchContext(sequence: seq, generator: generator))
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
        
        if let next = token as? WhiteSpaceToken {
            token = getNext()
        }
        
        return token
    }
}

class BranchTokenSequence : SequenceType {
    var token:BranchToken
    var branchStack:Stack<BranchContext>
    var currentIndex:Int
    
    init (_ token:BranchToken) {
        self.token = token
        currentIndex = -1
        branchStack = Stack<BranchContext>()
    }
    
    func generate() -> AnyGenerator<Token> {
        return anyGenerator({
            if let b = self.branchStack.lastItem() {
                if let next = b.generator.next() {
                    return next
                } else {
                    self.branchStack.pop()
                }
            }
            
            let bodyToken = self.getNext()
            if let nextToken = bodyToken {
                if let branchToken = nextToken as? BranchToken {
                    let seq = BranchTokenSequence(branchToken)
                    let generator = seq.generate()
                    self.branchStack.push(BranchContext(sequence: seq, generator: generator))
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
