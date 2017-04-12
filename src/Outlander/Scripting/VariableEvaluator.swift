//
//  VariableEvaluator.swift
//  Outlander
//
//  Created by Joseph McBride on 4/11/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

class VariableEvaluator {

    func eval(_ input:String, _ context:ScriptContext) -> String {
        let mutable = input.mutable

        var count = 0
        let maxIterations = 15

        var last:String? = nil

        repeat {
            last = String(mutable)
            simplifyImpl(mutable, context)
            count += 1
        } while count < maxIterations && last != mutable as String && hasPotentialVars(mutable)

        return String(mutable)
    }

    private func hasPotentialVars(_ mutable:NSMutableString) -> Bool {

        if (mutable.range(of: "$").location != NSNotFound) { return true }
        if (mutable.range(of: "%").location != NSNotFound) { return true }
        if (mutable.range(of: "&").location != NSNotFound) { return true }

        return false
    }

    private func simplifyImpl(_ mutable:NSMutableString, _ context:ScriptContext) {

        if context.actionVars.count > 0 && mutable.range(of: "$").location != NSNotFound {
            self.replace("\\$", mutable, context.actionVars)
        }

        if context.regexVars.count > 0 && mutable.range(of: "$").location != NSNotFound {
            self.replace("\\$", mutable, context.regexVars)
        }

        if mutable.range(of: "%").location != NSNotFound {
            self.replace("%", mutable, context.variables)
            self.replace("%", mutable, context.argVars)
        }

        if mutable.range(of: "$").location != NSNotFound {
            self.replace("\\$", mutable, context.globalVars())
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
