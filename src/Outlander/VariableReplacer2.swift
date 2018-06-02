//
//  VariableReplacer2.swift
//  Outlander
//
//  Created by Joseph McBride on 6/1/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation

@objc
public class VariableReplacer2 : NSObject {
    
    class func newInstance() -> VariableReplacer2 {
        return VariableReplacer2()
    }

    public func simplify(
        data:String,
        _ globalVars:[String:String],
        _ regexVars:[String:String] = [:],
        _ actionVars:[String:String] = [:],
        _ variables:[String:String] = [:],
        _ paramVars:[String:String] = [:]
        ) -> String {

        let mutable = RegexMutable(data)

        var count = 0
        let maxIterations = 15

        var last:String? = nil

        repeat {
            last = String(mutable)
            simplifyImpl(mutable, globalVars, regexVars, actionVars, variables, paramVars)
            count += 1
        } while count < maxIterations && last != mutable && hasPotentialVars(mutable)

        return String(mutable)
    }

    private func hasPotentialVars(mutable:NSMutableString)->Bool {

        if (mutable.rangeOfString("$").location != NSNotFound) { return true }
        if (mutable.rangeOfString("%").location != NSNotFound) { return true }

        return false
    }

    private func simplifyImpl(
        mutable:NSMutableString,
        _ globalVars:[String:String],
        _ regexVars:[String:String] = [:],
        _ actionVars:[String:String] = [:],
        _ variables:[String:String] = [:],
        _ paramVars:[String:String] = [:]
        )->Void {

        if actionVars.count > 0 && mutable.rangeOfString("$").location != NSNotFound {
            self.replace("\\$", target: mutable, dict: actionVars)
        }

        if regexVars.count > 0 && mutable.rangeOfString("$").location != NSNotFound {

            self.replace("\\$", target: mutable, dict: regexVars)
        }

        if mutable.rangeOfString("%").location != NSNotFound {

            self.replace("%", target: mutable, dict: variables)
            self.replace("%", target: mutable, dict: paramVars)
        }

        if globalVars.count > 0 && mutable.rangeOfString("$").location != NSNotFound {

            self.replace("\\$", target: mutable, dict: globalVars)
        }
    }

    private func replace(prefix:String, target:NSMutableString, dict:[String:String]) {

        let sortedKeys = dict.keys.sort({ $0.0.characters.count > $0.1.characters.count })

        func doReplace() {
            for key in sortedKeys {

                let replaceCanidate = "\(prefix.trimPrefix("\\"))\(key)"

                if target.containsString(replaceCanidate) {
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
        while count < maxIterations && target.containsString(prefix.trimPrefix("\\"))
    }
}
