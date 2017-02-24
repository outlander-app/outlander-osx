//
//  ExpressionEvaluatorTester.swift
//  Outlander
//
//  Created by Joseph McBride on 12/1/15.
//  Copyright © 2015 Joe McBride. All rights reserved.
//

import Foundation
import OysterKit
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
                let result = evaluator.eval(context, iftoken.expression, context.simplify)
                
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
                let result = evaluator.eval(context, iftoken.expression, context.simplify)
                
                let boolResult = context.getBoolResult(result.result)
                
                expect(boolResult).to(equal(true))
            }

            it("evaluates matchre expression") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = [:]
                    return res
                }
                
                let script = "if matchre(\"%dir\", \"^(search|swim|climb) \") then { send hello }"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                context.setVariable("dir", value: "swim north")
                
                let evaluator = ExpressionEvaluator()
                let iftoken = tokens[0] as! IfToken
                let result = evaluator.eval(context, iftoken.expression, context.simplify)
                
                let boolResult = context.getBoolResult(result.result)
                
                expect(boolResult).to(equal(true))
                expect(result.matchGroups?.count).to(equal(2))
            }
            
            it("properly replaces lefthandnoun") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = [
                        "lefthand":"icesteel tongs",
                        "lefthandnoun":"tongs"
                    ]
                    return res
                }
                
                let script = "put $lefthandnoun"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                
                let result = context.simplify(script);
                
                expect(result).to(equal("put tongs"))
            }
            
            it("properly replaces combined local/global vars") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = [
                        "Arcana.LearningRate":"34"
                    ]
                    return res
                }
                
                let script = "var maxexp $%magicToTrain.LearningRate"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                context.setVariable("magicToTrain", value: "Arcana")
                
                let result = context.simplify(script);
                
                expect(result).to(equal("var maxexp 34"))
            }
            
            it("properly replaces combined local variables") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = [:]
                    return res
                }
                
                let script = "echo %%yy-var"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                context.setVariable("xx-var", value: "abcdef")
                context.setVariable("yy", value: "xx")
                
                let result = context.simplify(script);
                
                expect(result).to(equal("echo abcdef"))
            }
            
            it("properly replaces combined local variables") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = [:]
                    return res
                }
                
                let script = "setVariable shopdiff %percentsign%storecodeQuant"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                context.setVariable("Chab", value: "skullcap")
                context.setVariable("ChabQuant", value: "2")
                context.setVariable("percentsign", value: "%")
                context.setVariable("storecode", value: "Chab")
                
                let result = context.simplify(script);
                
                expect(result).to(equal("setVariable shopdiff 2"))
            }
            
            it("properly replaces combined global variables") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = [
                        "MagicToTrain" : "Arcana",
                        "Arcana.LearningRate" : "34"
                    ]
                    return res
                }
                
                let script = "echo $$MagicToTrain.LearningRate"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                
                let result = context.simplify(script);
                
                expect(result).to(equal("echo 34"))
            }
            
            it("properly breaks with non-matched local variables") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = [:]
                    return res
                }
                
                let script = "echo %%yy-var"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                context.setVariable("yy", value: "xx")
                
                let result = context.simplify(script);
                
                expect(result).to(equal("echo %xx-var"))
            }
            
            it("eval replacere") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = [:]
                    return res
                }
                
                let script = "eval movement replacere(\"%movement\", \"^(swim|web|muck|rt|wait|slow|script|room) \", \"\")"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                context.setVariable("movement", value: "rt north")
                
                let evaluator = ExpressionEvaluator()
                let evalResult = evaluator.eval(context, tokens, context.simplify)
                let result = self.getStringResult(evalResult.result)
                
                expect(result).to(equal("north"))
            }
            
            it("eval replacere sets match groups") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = [:]
                    return res
                }
                
                let script = "eval type replacere(\"%movement\", \"^(swim|web|muck|rt|wait|slow|script|room) \", \"\")"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                context.setVariable("movement", value: "rt north")
                
                let evalTokens:[Token] = [tokens[0]]
                
                let evaluator = ExpressionEvaluator()
                let result = evaluator.eval(context, evalTokens, context.simplify)
                
                expect(result.matchGroups?.count).to(equal(2))
                expect(result.matchGroups?[1]).to(equal("rt"))
            }
            
            it("eval countsplit") {
                let parser = OutlanderScriptParser()
                
                let vars = { () -> [String:String] in
                    let res:[String:String] = [:]
                    return res
                }
                
                let script = "eval count countsplit(%equipment, \"|\")"
                
                let tokens = parser.parseString(script)
                
                let context = ScriptContext(tokens, globalVars: vars, params: [])
                context.setVariable("equipment", value: "targe|shirt|pants")
                
                let evaluator = ExpressionEvaluator()
                let evalResult = evaluator.eval(context, tokens, context.simplify)
                let result = self.getStringResult(evalResult.result)
                
                expect(result).to(equal("3"))
            }
        }
    }
    
    private func getStringResult(result:EvalResult) -> String {
        switch(result) {
        case .Str(let x):
            return x
        default:
            return ""
        }
    }
}
