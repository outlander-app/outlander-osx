//
//  VariableEvaluator.swift
//  Outlander
//
//  Created by Joseph McBride on 4/11/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

struct VariableSetting {
    var token:String
    var replaceToken:String
    var values:[String:String]
    var sortedKeys:[String]
}

class VariableContext {
    var settings:[VariableSetting] = []

    var keys:[String] {
        return settings.map { $0.token }.unique()
    }

    func add(_ token:String, _ replaceToken:String, _ values:[String:String]) {
        let sortedKeys = values.keys.sorted(by: { $0.0.characters.count > $0.1.characters.count })
        self.settings.append(VariableSetting(token: token, replaceToken: replaceToken, values: values, sortedKeys: sortedKeys))
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

class VariableEvaluator {

    func eval(_ input:String, _ context:VariableContext) -> String {

        var results:[String] = []

        let vars = ScriptParser().parseVariables(input)

        for v in vars {
            switch v {
            case let .value(val): results.append(val)
            case let .indexed(target, idx):
                let evaledTarget = evalStr(target, context)
                let evaledIdx = evalStr(idx, context)

                guard let idxNum = Int(evaledIdx) else {
                    results.append("\(target)[\(idx)]")
                    continue
                }

                let list = evaledTarget.components(separatedBy: "|")
                guard idxNum < list.count else {
                    results.append("\(target)[\(idx)]")
                    continue
                }

                let val = list[idxNum]
                results.append(val)
            }
        }

        let combined = results.joined(separator: " ")
        return evalStr(combined, context)
    }

    func evalStr(_ input:String, _ context:VariableContext) -> String {
        let mutable = input.mutable

        var count = 0
        let maxIterations = 7

        var last:String? = nil

        repeat {
            last = String(mutable)
            simplifyImpl(mutable, context)
            count += 1
        } while count < maxIterations && last != String(mutable) && hasPotentialVars(mutable, context)

//        print(count)

        return String(mutable)
    }

    private func hasPotentialVars(_ mutable:NSMutableString, _ context:VariableContext) -> Bool {

        for key in context.keys {
            if mutable.range(of: key).location != NSNotFound { return true }
        }

        return false
    }

    private func simplifyImpl(_ mutable:NSMutableString, _ context:VariableContext) {

        for setting in context.settings {
            if setting.values.count > 0 && mutable.range(of: setting.token).location != NSNotFound {
                self.replace(setting.token, setting.replaceToken, mutable, setting.values, setting.sortedKeys)
            }
        }
    }

    private func replace(_ token:String, _ prefix:String, _ target:NSMutableString, _ dict:[String:String], _ sortedKeys:[String]) {

        var last = ""

        func doReplace() {
            for key in sortedKeys {

                let replaceCanidate = "\(token)\(key)"

                if target.contains(replaceCanidate) {
                    target["\(prefix)\(key)"] ~= dict[key] ?? ""
                    break
                }
            }
        }

        let maxIterations = 7
        var count = 0

        repeat {
            last = String(target)
            doReplace()
            count += 1
        }
        while count < maxIterations && last != String(target) && target.contains(token)

//        print("inner count: \(count)")
    }
}
