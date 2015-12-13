//
//  ExpressionEvaluatorTester.swift
//  Outlander
//
//  Created by Joseph McBride on 12/1/15.
//  Copyright © 2015 Joe McBride. All rights reserved.
//

import Foundation
import Quick
import Nimble

class ExpressionEvaluatorTester : QuickSpec {
    
    override func spec() {
        
        describe("expression evaluator") {
            
            beforeEach {
            }
            
            it("evaluates if expression") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = ["righthand":"mace"]
                    return res
                }
                
                let script = "if (\"$righthand\" = \"mace\") then { send hello }"
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                
                let evaluator = ExpressionEvaluator()
                let iftoken = tokens[0] as! IfToken
                let result = evaluator.eval(iftoken.expression, context.simplify)
                
                let boolResult = context.getBoolResult(result.result)
                
                expect(boolResult).to(equal(true))
            }
            
            it("evaluates contains expression") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = ["lefthand":"icesteel tongs"]
                    return res
                }
                
                let script = "if !contains(\"$lefthand\", \"%tool\") then { send hello }"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                context.setVariable("tool", value: "bellows")
                
                let evaluator = ExpressionEvaluator()
                let iftoken = tokens[0] as! IfToken
                let result = evaluator.eval(iftoken.expression, context.simplify)
                
                let boolResult = context.getBoolResult(result.result)
                
                expect(boolResult).to(equal(true))
            }
        }
    }
}