//
//  VariableEvaluatorTester.swift
//  Outlander
//
//  Created by Joseph McBride on 4/11/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation
import Quick
import Nimble

class VariableEvaluatorTester : QuickSpec {

    override func spec() {

        let evaluator = VariableEvaluator()
        let gameContext = GameContext()
        let context = ScriptContext({
            return gameContext.globalVars.copyValues() as! [String:String]
        })

        describe("variable evaluator") {

            beforeEach() {
            }

            func simplify(_ text:String) -> String {
                return evaluator.eval(text, context.defaultSettings())
            }

            describe("evals") {
                it("label vars") {
                    context.labelVars["0"] = "one"

                    let result = simplify("echo &0")

                    expect(result).to(equal("echo one"))
                }

                it("longer variables first") {
                    gameContext.variable("lefthandnoun", "tongs")
                    gameContext.variable("lefthand", "icesteel tongs")

                    let result = simplify("put $lefthandnoun")

                    expect(result).to(equal("put tongs"))
                }

                it("replaces combined local/global vars") {
                    gameContext.variable("Arcana.LearningRate", "34")

                    context.variables["magicToTrain"] = "Arcana"

                    let result = simplify("$%magicToTrain.LearningRate")

                    expect(result).to(equal("34"))
                }

                it("replaces combined local variables") {
                    context.variables["Chab"] = "skullcap"
                    context.variables["ChabQuant"] = "2"
                    context.variables["percentsign"] = "%"
                    context.variables["storecode"] = "Chab"

                    let result = simplify("%percentsign%storecodeQuant")

                    expect(result).to(equal("2"))
                }

                it("replaces combined global vars") {
                    gameContext.variable("magicToTrain", "Arcana")
                    gameContext.variable("Arcana.LearningRate", "34")

                    let result = simplify("$$magicToTrain.LearningRate")

                    expect(result).to(equal("34"))
                }

                it("properly breaks with non-matched local variables") {
                    context.variables["yy"] = "xx"

                    let result = simplify("%%yy-var")

                    expect(result).to(equal("%xx-var"))
                }
            }
        }
    }
}
