//
//  FunctionEvaluator.swift
//  Outlander
//
//  Created by Joseph McBride on 4/19/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

struct EvalResult {
    var text:String
    var result:Bool
    var groups:[String]
}

class FunctionEvaluator {

    private let simplify:(String) -> String
    private let evaluator:ExpressionEvaluator

    init(_ simplify:@escaping (String)->String) {
        self.simplify = simplify
        self.evaluator = ExpressionEvaluator()
    }

    func evaluate(_ e:Expression) -> EvalResult {
        switch e {
        case .value(let val):
            let simp = self.simplify(val)
            return EvalResult(text: simp, result: self.evaluator.evaluateLogic(simp), groups: [])
        case .function(let name, let args):
            let simp = self.simplify(args)
            let (result, groups) = executeFunction(name, simp)
            let text = "\(name)(\(simp))"
            return EvalResult(text: text, result: result, groups: groups)
        }
    }

    func executeFunction(_ name:String, _ argsFlat:String) -> (Bool, [String]) {
        guard let (res, _) = ScriptParser().functionArgs().run(argsFlat) else {
            return (false, [])
        }

        let args = res.map { $0.trim("\"") }

        switch name.lowercased() {
        case "contains":
            if args.count != 2 { return (false, []) }
            return (args[0].contains(args[1]), [])
        case "matchre":
            if args.count != 2 { return (false, []) }
            let groups = res[0][args[1]].firstGroup()
            return (groups.count > 0, groups)
        default:
            return (false, [])
        }
    }
}
