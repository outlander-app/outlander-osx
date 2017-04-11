//
//  ScriptContext.swift
//  Outlander
//
//  Created by Joseph McBride on 4/10/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

class ScriptContext {
    var lines: [ScriptLine] = []
    var labels: [String:Label] = [:]
    var currentLineNumber:Int = -1
    var params:[String] = []
    var paramVars: [String:String] = [:]
    var variables: [String:String] = [:]
    var ifStack:Stack<ScriptLine> = Stack<ScriptLine>()
    var ifResultStack:Stack<Bool> = Stack<Bool>()

    var globalVar:((String) -> String?) = { _ in nil }

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
        return self.globalVar("roundtime")?.toDouble()
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
        return text
    }
}
