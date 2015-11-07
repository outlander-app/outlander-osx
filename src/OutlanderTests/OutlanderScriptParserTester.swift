//
//  OutlanderScriptParserTester.swift
//  Outlander
//
//  Created by Joseph McBride on 11/7/15.
//  Copyright © 2015 Joe McBride. All rights reserved.
//
import Foundation
import Quick
import Nimble

class OutlanderScriptParserTester : QuickSpec {
    
    override func spec() {
        
        describe("parser") {
            
            var parser:OutlanderScriptParser?
            var toMessage:TokenToMessage?
            
            beforeEach {
                parser = OutlanderScriptParser()
                toMessage = TokenToMessage()
            }
            
            it("echo message") {
                let script = "echo a message"
                let context = ScriptContext([], globalVars: nil, params: [])
                
                let tokens = parser!.parseString(script)
                expect(tokens.count).to(equal(1))
                
                let message = toMessage!.toMessage(context, token: tokens[0])
                
                let msg = message as? EchoMessage
                
                expect(msg != nil).to(equal(true))
                expect(msg!.name).to(equal("echo"))
                expect(msg!.message).to(equal("a message"))
            }
            
            it("eval message") {
                let script = "eval twoCount countsplit(%two, \"|\")"
                let context = ScriptContext([], globalVars: nil, params: [])
                
                let tokens = parser!.parseString(script)
                expect(tokens.count).to(equal(1))
                
                let message = toMessage!.toMessage(context, token: tokens[0])
                
                let msg = message as? EvalMessage
                
                expect(msg != nil).to(equal(true))
                expect(msg!.name).to(equal("eval"))
                expect(msg!.token.variable).to(equal("twoCount"))
                
                let funcToken = msg!.token.expression[1] as? FuncToken
                expect(funcToken != nil).to(equal(true))
                expect(funcToken!.name).to(equal("countsplit"))
                
                expect(funcToken!.body[0].name).to(equal("globalvar"))
                expect(funcToken!.body[0].characters).to(equal("%two"))
                
                expect(funcToken!.body[3].name).to(equal("quoted-string"))
                expect(funcToken!.body[3].characters).to(equal("|"))
            }
            
            it("put message") {
                let script = "put #var something"
                let context = ScriptContext([], globalVars: nil, params: [])
                
                let tokens = parser!.parseString(script)
                expect(tokens.count).to(equal(1))
                
                let message = toMessage!.toMessage(context, token: tokens[0])
                
                let msg = message as? PutMessage
                
                expect(msg != nil).to(equal(true))
                expect(msg!.name).to(equal("put"))
                expect(msg!.message).to(equal("#var something"))
            }
        }
    }
}