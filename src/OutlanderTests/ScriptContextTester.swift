//
//  ScriptContextTester.swift
//  Outlander
//
//  Created by Joseph McBride on 3/29/16.
//  Copyright © 2016 Joe McBride. All rights reserved.
//

import Foundation
import OysterKit
import Quick
import Nimble

class ScriptContextTester : QuickSpec {
    
    override func spec() {

        var context:GameContext = GameContext()
        
        describe("script context") {
            
            beforeEach {
                context = GameContext()
            }
            
            it("shift updates argcount") {
                
                let paramVars = ["one", "two", "three four"]
                
                let context = ScriptContext([], context: context, params: paramVars)
                
                expect(context.getVariable("argcount")).to(equal("3"))
                
                context.shiftParamVars()
                
                expect(context.getVariable("argcount")).to(equal("2"))
                
                context.shiftParamVars()
                context.shiftParamVars()
                
                expect(context.getVariable("argcount")).to(equal("0"))
            }
            
            it("sets param variables") {
                
                let paramVars = ["one", "two", "three four"]
                
                let context = ScriptContext([], context: context, params: paramVars)
                
                expect(context.getParamVar("0")).to(equal("one two \"three four\""))
                expect(context.getParamVar("1")).to(equal("one"))
                expect(context.getParamVar("2")).to(equal("two"))
                expect(context.getParamVar("3")).to(equal("three four"))
            }
            
            it("sets param variables on shift") {
                
                let paramVars = ["one", "two", "three four"]
                
                let context = ScriptContext([], context: context, params: paramVars)
                
                context.shiftParamVars()
                
                expect(context.getParamVar("0")).to(equal("two \"three four\""))
                expect(context.getParamVar("1")).to(equal("two"))
                expect(context.getParamVar("2")).to(equal("three four"))
                expect(context.getParamVar("3")).to(equal(""))
            }
            
            it("sets param variables on shift to empty") {
                
                let paramVars = ["one", "two", "three four"]
                
                let context = ScriptContext([], context: context, params: paramVars)
                
                context.shiftParamVars()
                context.shiftParamVars()
                context.shiftParamVars()
                
                expect(context.getParamVar("0")).to(equal(""))
                expect(context.getParamVar("1")).to(equal(""))
                expect(context.getParamVar("2")).to(equal(""))
                expect(context.getParamVar("3")).to(equal(""))
            }
        }
    }
}
