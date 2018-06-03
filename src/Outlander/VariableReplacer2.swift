//
//  VariableReplacer2.swift
//  Outlander
//
//  Created by Joseph McBride on 6/1/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation

protocol StringProtocol : Equatable, Comparable {
    var characters: String.CharacterView { get }
}
extension String : StringProtocol {}

extension Dictionary where Key:StringProtocol {
    var keysByLength : [Key] {
        return self.keys.sort({ $0.0.characters.count > $0.1.characters.count })
    }

    var keysByAlpha : [Key] {
        return self.keys.sort({ $0.0 < $0.1 })
    }

    func getValue(key:Key) -> Value? {
        return self[key]
    }
}

@objc
public class VariableReplacer2 : NSObject {
    
    class func newInstance() -> VariableReplacer2 {
        return VariableReplacer2()
    }

    public func simplify(
        data:String,
        _ globalVars:GlobalVariables,
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
        _ globalVars:GlobalVariables,
        _ regexVars:[String:String] = [:],
        _ actionVars:[String:String] = [:],
        _ variables:[String:String] = [:],
        _ paramVars:[String:String] = [:]
        )->Void {

        if actionVars.count > 0 && mutable.rangeOfString("$").location != NSNotFound {
            self.replace("\\$", target: mutable, dict: actionVars.getValue, sortedKeys: actionVars.keysByLength)
        }

        if regexVars.count > 0 && mutable.rangeOfString("$").location != NSNotFound {

            self.replace("\\$", target: mutable, dict: regexVars.getValue, sortedKeys: regexVars.keysByLength)
        }

        if mutable.rangeOfString("%").location != NSNotFound {

            self.replace("%", target: mutable, dict: variables.getValue, sortedKeys: variables.keysByLength)
            self.replace("%", target: mutable, dict: paramVars.getValue, sortedKeys: paramVars.keysByLength)
        }

        if globalVars.count > 0 && mutable.rangeOfString("$").location != NSNotFound {

            self.replace(
                "\\$",
                target: mutable,
                dict: globalVars.get,
                sortedKeys: globalVars.keys)
        }
    }

    private func replace(prefix:String, target:NSMutableString, dict:(String)->String?, sortedKeys:[String]) {

        func doReplace() {
            for key in sortedKeys {

                let replaceCandidate = "\(prefix.trimPrefix("\\"))\(key)"

                if target.containsString(replaceCandidate) {
                    target["\(prefix)\(key)"] ~= dict(key) ?? ""
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
