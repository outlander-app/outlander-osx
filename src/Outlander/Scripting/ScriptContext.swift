//
//  ScriptContext.swift
//  Outlander
//
//  Created by Joseph McBride on 4/10/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

struct Label {
    var name: String
    var line: Int
    var fileName: String
}

class ScriptContext {
    var lines: [ScriptLine] = []
    var labels: [String:Label] = [:]
    var currentLineNumber:Int = -1
    var args:[String] = []
    var argVars:[String:String] = [:]
    var variables:[String:String] = [:]
    var actionVars:[String:String] = [:]
    var regexVars:[String:String] = [:]
    var labelVars:[String:String] = [:]

    var ifStack:Stack<ScriptLine> = Stack<ScriptLine>()
    var ifResultStack:Stack<Bool> = Stack<Bool>()

    var globalVars:(()->[String:String])
    var variableEvaluator:VariableEvaluator = VariableEvaluator()

    init(_ globalVars: @escaping ()->[String:String]) {
        self.globalVars = globalVars
    }

    var currentLine:ScriptLine? {
        get {
            if currentLineNumber < 0 || currentLineNumber >= lines.count {
                return nil
            }

            return lines[currentLineNumber]
        }
    }

    var previousLine:ScriptLine? {
        if currentLineNumber - 1 < 0 {
            return nil
        }

        return lines[currentLineNumber - 1]
    }

    var roundtime:Double? {
        return self.globalVars()["roundtime"]?.toDouble()
    }

    func shiftArgumentVars() -> Bool {
        guard let _ = self.args.first else {
            return false
        }

        self.args.remove(at: 0)
        self.updateArgumentVars()
        return true
    }

    func updateArgumentVars() {
        self.argVars = [:]

        var all = ""

        for param in self.args {
            if param.contains(" ") {
                all += " \"\(param)\""
            } else {
                all += " \(param)"
            }
        }

        self.argVars["0"] = all.trimmingCharacters(in: CharacterSet.whitespaces)

        for (index, param) in self.args.enumerated() {
            self.argVars["\(index+1)"] = param
        }

        let originalCount = self.args.count

        let maxArgs = 9

        let diff = maxArgs - originalCount

        if(diff > 0) {
            let start = maxArgs - diff
            for index in start..<(maxArgs) {
                self.argVars["\(index+1)"] = ""
            }
        }

        self.variables["argcount"] = "\(originalCount)"
    }

    func consumeToken(_ token:String) -> Bool {
        self.advance()
        return currentLineTokenValueIs(token)
    }

    func currentLineTokenValueIs(_ token:String) -> Bool {
        guard let line = self.currentLine else {
            return false
        }

        if line.token == nil {
            line.token = ScriptParser().parse(line.originalText)
        }

        guard let t = line.token else {
            return false
        }
        guard case let .token(v) = t else {
            return false
        }

        return v == token
    }

    func pushCurrentLineToIfStack() -> Bool {
        guard let line = self.currentLine else {
            return false
        }

        return pushLineToIfStack(line)
    }

    func pushLineToIfStack(_ line:ScriptLine) -> Bool {
        self.ifStack.push(line)
        return true
    }

    func popIfStack() -> (Bool, ScriptLine?) {
        guard self.ifStack.hasItems() else {
            return (false, nil)
        }

        let line = self.ifStack.pop()
        return (true, line)
    }

    func advance() {
        currentLineNumber += 1
    }

    func retreat() {
        currentLineNumber -= 1
    }

    func advanceToNextBlock() -> Bool {
        guard let target = self.ifStack.last else {
            return false
        }

        if let endOfBlock = target.endOfBlock {
            self.currentLineNumber = endOfBlock
            return true
        }

        while currentLineNumber < lines.count {

            self.advance()

            guard let line = self.currentLine else {
                return false
            }

            guard let currentIf = self.ifStack.last else {
                return false
            }

            if line.token == nil {
                line.token = ScriptParser().parse(line.originalText)
            }

            guard let lineToken = line.token else {
                continue
            }

            switch lineToken {
            case .token(let element):
                if element == "}" {

                    if currentIf.lineNumber == target.lineNumber {
                        _ = self.popIfStack()
                        currentIf.endOfBlock = self.currentLineNumber
                        return true
                    }

                    let (popped, _) = self.popIfStack()
                    if !popped {
                        return false
                    }
                }
            case .ifArgSingle: return true
            case .ifArg:
                if !self.pushCurrentLineToIfStack() {
                    return false
                }
            case .ifArgNeedsBrace:
                if !self.pushCurrentLineToIfStack() {
                    return false
                }
                if !self.consumeToken("{") {
                    return false
                }
            case .ifSingle: return true
            case .If:
                if !self.pushCurrentLineToIfStack() {
                    return false
                }
            case .ifNeedsBrace:
                if !self.pushCurrentLineToIfStack() {
                    return false
                }
                if !self.consumeToken("{") {
                    return false
                }
            case .elseSingle: return true
            case .Else:
                if !self.pushCurrentLineToIfStack() {
                    return false
                }
            case .elseNeedsBrace:
                if !self.pushCurrentLineToIfStack() {
                    return false
                }
                if !self.consumeToken("{") {
                    return false
                }
            default:
                continue
            }
        }

        return false
    }

    func advanceToEndOfBlock() -> Bool {

        while currentLineNumber < lines.count {

            self.advance()

            guard let line = self.currentLine else {
                return false
            }

            if line.token == nil {
                line.token = ScriptParser().parse(line.originalText)
            }

            guard let lineToken = line.token else {
                return false
            }

            if !self.ifStack.hasItems() && lineToken.isTopLevelIf {
                self.retreat()
                return true
            }

            if lineToken.isSingleToken {
                continue
            }

            if lineToken.isIfToken || lineToken.isElseToken {
                _ = self.pushCurrentLineToIfStack()
                if !self.advanceToNextBlock() {
                    return false
                }
                continue
            }
            else {
                self.retreat()
                return true
            }
        }
        
        return false
    }
    
    func simplify(_ text:String) -> String {
        return self.variableEvaluator.eval(text, self.defaultSettings())
    }

    func simplifyAction(_ text:String) -> String {
        return self.variableEvaluator.eval(text, self.actionSettings())
    }

    func actionSettings() -> VariableContext {
        let ctx = VariableContext()
        ctx.add("$", "\\$", self.actionVars)
        ctx.add("%", "%", self.variables)
        ctx.add("%", "%", self.argVars)
        ctx.add("$", "\\$", self.globalVars())
        return ctx
    }

    func defaultSettings() -> VariableContext {
        let ctx = VariableContext()
        ctx.add("$", "\\$", self.regexVars)
        ctx.add("&", "&", self.labelVars)
        ctx.add("%", "%", self.variables)
        ctx.add("%", "%", self.argVars)
        ctx.add("$", "\\$", self.globalVars())
        return ctx
    }

    func setRegexVars(_ vars:[String]) {
        self.regexVars = [:]

        for (index, param) in vars.enumerated() {
            self.regexVars["\(index)"] = param
        }
    }

    func setLabelVars(_ vars:[String]) {
        self.labelVars = [:]

        for (index, param) in vars.enumerated() {
            self.labelVars["\(index)"] = param
        }
    }
    
    func setActionVars(_ vars:[String]) {
        self.actionVars = [:]

        for (index, param) in vars.enumerated() {
            self.actionVars["\(index)"] = param
        }
    }
}
