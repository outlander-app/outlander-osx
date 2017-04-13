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
}

class VariableContext {
    var settings:[VariableSetting] = []

    var keys:[String] {
        return settings.map { $0.token }.unique()
    }

    func add(_ token:String, _ replaceToken:String, _ values:[String:String]) {
        self.settings.append(VariableSetting(token: token, replaceToken: replaceToken, values: values))
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
        let mutable = input.mutable

        var count = 0
        let maxIterations = 15

        var last:String? = nil

        repeat {
            last = String(mutable)
            simplifyImpl(mutable, context)
            count += 1
        } while count < maxIterations && last != mutable as String && hasPotentialVars(mutable, context)

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
                self.replace(setting.replaceToken, mutable, setting.values)
            }
        }
    }

    private func replace(_ prefix:String, _ target:NSMutableString, _ dict:[String:String]) {

        let sortedKeys = dict.keys.sorted(by: { $0.0.characters.count > $0.1.characters.count })

        func doReplace() {
            for key in sortedKeys {

                let replaceCanidate = "\(prefix.trimPrefix("\\"))\(key)"

                if target.contains(replaceCanidate) {
                    target["\(prefix)\(key)"] ~= dict[key] ?? ""
                    break
                }
            }
        }

        let maxIterations = 15
        var count = 0

        repeat {
            doReplace()
            count += 1
        }
        while count < maxIterations && target.contains(prefix.trimPrefix("\\"))
    }
}
