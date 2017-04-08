//
//  ExpressionEvaluatorTester.swift
//  Outlander
//
//  Created by Joseph McBride on 4/7/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation
import Nimble
import Quick

class ExpressionEvaluatorTester : QuickSpec {

    override func spec() {

        let evaluator = ExpressionEvaluator()

        describe("the expression") {

            beforeEach() {
            }

            describe("logic") {
                it("evals nothing") {
                    let result = evaluator.evaluateLogic("")
                    expect(result).to(beFalse())
                }

                it("evals nothing") {
                    let result = evaluator.evaluateLogic("3")
                    expect(result).to(beFalse())
                }

                it("evals numbers") {
                    let result = evaluator.evaluateLogic("1 > 2")
                    expect(result).to(beFalse())
                }

                it("evals strings") {
                    var result = evaluator.evaluateLogic("one > two")
                    expect(result).to(beFalse())

                    result = evaluator.evaluateLogic("two > one")
                    expect(result).to(beFalse())
                }

                it("evals string equality") {
                    var result = evaluator.evaluateLogic("\"one\" == \"two\"")
                    expect(result).to(beFalse())

                    result = evaluator.evaluateLogic("\"one\" = \"two\"")
                    expect(result).to(beFalse())

                    result = evaluator.evaluateLogic("one == two")
                    expect(result).to(beTrue())

                    result = evaluator.evaluateLogic("one = two")
                    expect(result).to(beTrue())

                    result = evaluator.evaluateLogic("two == two")
                    expect(result).to(beTrue())

                    result = evaluator.evaluateLogic("two = two")
                    expect(result).to(beTrue())

                    result = evaluator.evaluateLogic("\"two\" = \"two\"")
                    expect(result).to(beTrue())
                    
                    result = evaluator.evaluateLogic("\"two\" == \"two\"")
                    expect(result).to(beTrue())

                    result = evaluator.evaluateLogic("two == \"two\"")
                    expect(result).to(beFalse())
                }

                it("evals expression") {
                    var result = evaluator.evaluateLogic("2+2=4")
                    expect(result).to(beTrue())

                    result = evaluator.evaluateLogic("2+2<4")
                    expect(result).to(beFalse())

                    result = evaluator.evaluateLogic("2+2<4 || 3*2=6")
                    expect(result).to(beTrue())
                }
            }

            describe("values") {
                it("can add numbers") {
                    let result:Int? = evaluator.evaluateValue("5 + 2")
                    expect(result).to(equal(7))
                }

                it("empty") {
                    let result:Int? = evaluator.evaluateValue("")
                    expect(result).to(beNil())
                }

                it("single") {
                    let result:Int? = evaluator.evaluateValue("5")
                    expect(result).to(equal(5))
                }

                it("single string") {
                    let result:Int? = evaluator.evaluateValue("abcd")
                    expect(result).to(beNil())
                }

                it("handles bogus") {
                    let result:Int? = evaluator.evaluateValue("one + %onetwo")
                    expect(result).to(beNil())
                }

                it("double") {
                    let result:Double? = evaluator.evaluateValue("3 + 3.5")
                    expect(result).to(equal(6.5))
                }

                it("double") {
                    let result:Double? = evaluator.evaluateValue("3 + 3")
                    expect(result).to(equal(6))
                }
            }
        }
    }
}
