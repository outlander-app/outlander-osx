//
//  ScriptOperations.swift
//  Outlander
//
//  Created by Joseph McBride on 4/3/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

class MoveOp : IWantStreamInfo {

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
