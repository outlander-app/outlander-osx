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
    var result:String
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
            let result = self.evaluator.evaluateLogic(simp)
            return EvalResult(text: simp, result: "\(result)", groups: [])
        case .function(let name, let args):
            let simp = self.simplify(args)
            let (result, groups) = executeFunction(name, simp)
            let text = "\(name)(\(simp))"
            return EvalResult(text: text, result: result, groups: groups)
        case .expression(let exp):
            return evaluate(exp)
        }
    }

    func evaluateValue(_ e:Expression) -> EvalResult {
        switch e {
        case .value(let val):
            let simp = self.simplify(val)
            guard let result:Double = self.evaluator.evaluateValue(simp) else {
                return EvalResult(text: simp, result: "0", groups: [])
            }
            return EvalResult(text: simp, result: "\(result)", groups: [])
        case .function(let name, let args):
            let simp = self.simplify(args)
            let (result, groups) = executeFunction(name, simp)
            let text = "\(name)(\(simp))"
            return EvalResult(text: text, result: result, groups: groups)
        case .expression(let exp):
            return evaluateValue(exp)
        }
    }

    func executeFunction(_ name:String, _ argsFlat:String) -> (String, [String]) {
        guard let (res, _) = ScriptParser().functionArgs().run(argsFlat) else {
            return ("false", [])
        }

        let args = res.map { $0.trim("\"") }

        switch name.lowercased() {
        case "contains":
            if args.count != 2 { return ("false", []) }
            let result = args[0].contains(args[1])
            return ("\(result)", [])
        case "matchre":
            if args.count != 2 { return ("false", []) }
            let groups = args[0][args[1]].firstGroup()
            let result = groups.count > 0
            return ("\(result)", groups)
        case "replacere":
            if args.count != 3 { return (argsFlat, []) }

            let mutable = args[0].mutable
            mutable[args[1]] ~= args[2]

            let result = String(mutable)
            return (result, [])
        case "tolower":
            if args.count != 1 { return (argsFlat, [])}
            return (args[0].lowercased(), [])
        case "toupper":
            if args.count != 1 { return (argsFlat, [])}
            return (args[0].uppercased(), [])
        case "len", "length":
            if args.count != 1 { return (argsFlat, [])}
            return ("\(args[0].characters.count)", [])
        case "endswith":
            if args.count != 2 { return (argsFlat, [])}
            let result = args[0].hasSuffix(args[1])
            return ("\(result)", [])
        case "startswith":
            if args.count != 2 { return (argsFlat, [])}
            let result = args[0].hasPrefix(args[1])
            return ("\(result)", [])
        case "count":
            if args.count != 2 { return (argsFlat, [])}
            let result = args[0].components(separatedBy: args[1]).count - 1
            return ("\(result)", [])
        case "countsplit":
            if args.count != 2 { return (argsFlat, [])}
            let result = args[0].components(separatedBy: args[1]).count
            return ("\(result)", [])
        case "trim":
            if args.count != 1 { return (argsFlat, [])}
            let result = args[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return ("\(result)", [])
        case "indexof":
            if args.count != 2 { return (argsFlat, [])}
            guard let range = args[0].range(of: args[1]) else {
                return ("-1", [])
            }
            let index:Int = args[0].distance(from: args[0].startIndex, to: range.lowerBound)
            return ("\(index)", [])
        default:
            return (argsFlat, [])
        }
    }
}
