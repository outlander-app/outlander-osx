//
//  ScriptOperations.swift
//  Outlander
//
//  Created by Joseph McBride on 4/3/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

class ActionOp : IAction {
    var id = ""
    var enabled:Bool

    var name:String
    var command:String
    var pattern:String
    var scriptLine:ScriptLine

    var commands:[TokenValue]

    var groups:[String]

    init(_ name:String, _ command:String, _ pattern:String, _ scriptLine:ScriptLine) {
        self.id = UUID().uuidString
        self.enabled = true

        self.name = name
        self.command = command
        self.pattern = pattern
        self.scriptLine = scriptLine

        self.commands = []

        self.groups = []
    }

    func stream(_ text:String, _ nodes:[Node], _ context:ScriptContext) -> CheckStreamResult {

        guard self.pattern.characters.count > 0 else {
            return CheckStreamResult.None
        }

        let simp = context.simplify(self.pattern)
        self.groups = text[simp].firstGroup()

        return self.groups.count > 0
            ? CheckStreamResult.Match(result: "action (line \(self.scriptLine.lineNumber)) triggered by:\(text)\n")
            : CheckStreamResult.None
    }

    func execute(_ script:IScript, _ context:ScriptContext) {
        context.setActionVars(self.groups)
        let simp = context.simplifyAction(self.command)
        let cmds = simp.splitToCommands()

        let parser = ScriptParser()

        for cmd in cmds {
            if let token = parser.parse(cmd) {
                print(token)
                let result = script.executeToken(self.scriptLine, token)
                switch result {
                case .next:
                    script.next()
                    return
                case .exit: script.stop()
                default: continue
                }
            }
        }
    }

    func vars(context:ScriptContext, vars:[String:String]) -> CheckStreamResult {
        return CheckStreamResult.None
    }
}

class MoveOp : IWantStreamInfo {

    var id = ""

    init() {
        self.id = UUID().uuidString
    }

    func stream(_ text:String, _ nodes:[Node], _ context:ScriptContext) -> CheckStreamResult {
        for node in nodes {

            if node.name == "compass" {
                return CheckStreamResult.Match(result: "")
            }
        }

        return CheckStreamResult.None
    }

    func execute(_ script:IScript, _ context:ScriptContext) {
        script.nextAfterRoundtime()
    }
}

class NextRoomOp : IWantStreamInfo {

    public var id = ""

    init() {
        self.id = UUID().uuidString
    }

    func stream(_ text:String, _ nodes:[Node], _ context:ScriptContext) -> CheckStreamResult {

        for node in nodes {

            if node.name == "compass" {
                return CheckStreamResult.Match(result: "")
            }
        }

        return CheckStreamResult.None
    }

    func execute(_ script:IScript, _ context:ScriptContext) {
        script.nextAfterRoundtime()
    }
}

class WaitEvalOp : IWantStreamInfo {

    var id = ""
    private let evaluator:ExpressionEvaluator
    private var expression:String

    init(_ expression:String) {
        self.id = UUID().uuidString
        self.evaluator = ExpressionEvaluator()
        self.expression = expression
    }

    func stream(_ text:String, _ nodes:[Node], _ context:ScriptContext) -> CheckStreamResult {

        for n in nodes {
            if n.name == "prompt" {
                let simplified = context.simplify(self.expression)
                if evaluator.evaluateLogic(simplified) {
                    return CheckStreamResult.Match(result: "true")
                }
            }
        }

        return CheckStreamResult.None
    }

    func execute(_ script:IScript, _ context:ScriptContext) {
        script.nextAfterRoundtime()
    }
}

class WaitforOp : IWantStreamInfo {

    public var id = ""
    let target:String

    init(_ target:String) {
        self.id = UUID().uuidString
        self.target = target
    }

    func stream(_ text:String, _ nodes:[Node], _ context:ScriptContext) -> CheckStreamResult {
        return text.range(of: context.simplify(self.target)) != nil
            ? CheckStreamResult.Match(result: text)
            : CheckStreamResult.None
    }

    func execute(_ script:IScript, _ context:ScriptContext) {
        script.nextAfterRoundtime()
    }
}

class WaitforReOp : IWantStreamInfo {

    public var id = ""
    var pattern:String
    var groups:[String]

    init(_ pattern:String) {
        self.id = UUID().uuidString
        self.pattern = pattern
        self.groups = []
    }

    func stream(_ text:String, _ nodes:[Node], _ context:ScriptContext) -> CheckStreamResult {
        let pattern = context.simplify(self.pattern)
        self.groups = text[pattern].firstGroup()
        return groups.count > 0 ? CheckStreamResult.Match(result: text) : CheckStreamResult.None
    }

    func execute(_ script:IScript, _ context:ScriptContext) {
        context.setRegexVars(self.groups)
        script.nextAfterRoundtime()
    }
}

class WaitforPromptOp : IWantStreamInfo {

    public var id = ""

    init() {
        self.id = UUID().uuidString
    }

    func stream(_ text:String, _ nodes:[Node], _ context:ScriptContext) -> CheckStreamResult {

        for n in nodes {
            if n.name == "prompt" {
                return CheckStreamResult.Match(result: text)
            }
        }

        return CheckStreamResult.None
    }

    func execute(_ script:IScript, _ context:ScriptContext) {
        script.nextAfterRoundtime()
    }
}
