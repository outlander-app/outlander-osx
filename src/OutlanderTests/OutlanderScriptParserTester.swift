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
            
            let parser = OutlanderScriptParser()
            let toMessage = TokenToMessage()
            
            beforeEach {
            }
            
            it("put message") {
                let script = "put #var something"
                let context = ScriptContext([], globalVars: nil, params: [])
                
                let tokens = parser.parseString(script)
                expect(tokens.count).to(equal(1))
                
                let message = toMessage.toMessage(context, token: tokens[0])
                
                let msg = message as? PutMessage
                
                expect(msg != nil).to(equal(true))
                expect(msg!.name).to(equal("put"))
                expect(msg!.message).to(equal("#var something"))
            }
        }
    }
}