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

struct MessageTestContext<T: Message> {
    var context:ScriptContext
    var message:T
}

class OutlanderScriptParserTester : QuickSpec {
    
    func buildMessage<T: Message>(script:String, _ globalVars: (()->[String:String])? = nil) -> MessageTestContext<T> {
        
        let parser = OutlanderScriptParser()
        let toMessage = TokenToMessage()
        
        let context = ScriptContext([], globalVars: globalVars, params: [])
        
        let tokens = parser.parseString(script)
        expect(tokens.count).to(equal(1))
        
        let message = toMessage.toMessage(context, token: tokens[0])
        
        return MessageTestContext(context: context, message: message as! T)
    }
    
    override func spec() {
        
        describe("parser") {
            
            beforeEach {
            }
            
            it("debug message") {
                let script = "debug 3"
                let ctx:MessageTestContext<DebugLevelMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("debug-level"))
                expect(ctx.message.level).to(equal(ScriptLogLevel.If))
            }
            
            it("debug message - defaults to Actions") {
                let script = "debuglevel"
                let ctx:MessageTestContext<DebugLevelMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("debug-level"))
                expect(ctx.message.level).to(equal(ScriptLogLevel.Actions))
            }
            
            it("echo message") {
                let script = "echo a message"
                let ctx:MessageTestContext<EchoMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("echo"))
                expect(ctx.message.message).to(equal("a message"))
            }
            
            it("eval message") {
                let script = "eval twoCount countsplit(%two, \"|\")"
                let ctx:MessageTestContext<EvalMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("eval"))
                expect(ctx.message.token.variable).to(equal("twoCount"))
                
                let funcToken = ctx.message.token.expression[1] as? FuncToken
                expect(funcToken != nil).to(equal(true))
                expect(funcToken!.name).to(equal("countsplit"))
                
                expect(funcToken!.body[0].name).to(equal("globalvar"))
                expect(funcToken!.body[0].characters).to(equal("%two"))
                
                expect(funcToken!.body[3].name).to(equal("quoted-string"))
                expect(funcToken!.body[3].characters).to(equal("|"))
            }
            
            it("exit message") {
                let script = "exit"
                let ctx:MessageTestContext<ExitMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("exit"))
            }
            
            it("goto message") {
                let script = "goto $alabel one $two"
                let vars = { () -> [String:String] in
                    let res:[String:String] = ["alabel":"mylabel", "two":"three"]
                    return res
                }
                let ctx:MessageTestContext<GotoMessage> = self.buildMessage(script, vars)
                
                expect(ctx.message.name).to(equal("goto"))
                expect(ctx.message.label).to(equal("mylabel"))
                expect(ctx.message.params.count).to(equal(3))
                expect(ctx.message.params[0]).to(equal("one three"))
                expect(ctx.message.params[1]).to(equal("one"))
                expect(ctx.message.params[2]).to(equal("three"))
            }
            
            it("matchwait message") {
                let script = "matchwait 3"
                let ctx:MessageTestContext<MatchwaitMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("matchwait"))
                expect(ctx.message.timeout).to(equal(3))
            }
            
            it("matchwait message - default") {
                let script = "matchwait"
                let ctx:MessageTestContext<MatchwaitMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("matchwait"))
                expect(ctx.message.timeout).to(beNil())
            }
            
            it("matchre message") {
                let script = "matchre one (two|three|four)"
                let ctx:MessageTestContext<MatchReMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("match"))
                expect(ctx.message.label).to(equal("one"))
                expect(ctx.message.value).to(equal("(two|three|four)"))
            }
            
            it("matchre with regex message") {
                let script = "matchre Done %material (\\s.*)?%item"
                let ctx:MessageTestContext<MatchReMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("match"))
                expect(ctx.message.label).to(equal("Done"))
                expect(ctx.message.value).to(equal("%material (\\s.*)?%item"))
            }
            
            it("math message - add") {
                let script = "math myvar add 2"
                let ctx:MessageTestContext<MathMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("math"))
                expect(ctx.message.variable).to(equal("myvar"))
                expect(ctx.message.operation).to(equal("add"))
                expect(ctx.message.number).to(equal(2))
            }
            
            it("math message - subtract") {
                let script = "math myvar subtract 3"
                let ctx:MessageTestContext<MathMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("math"))
                expect(ctx.message.variable).to(equal("myvar"))
                expect(ctx.message.operation).to(equal("subtract"))
                expect(ctx.message.number).to(equal(3))
            }
            
            it("pause message") {
                let script = "pause 0.5"
                let ctx:MessageTestContext<PauseMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("pause"))
                expect(ctx.message.seconds).to(equal(0.5))
            }
            
            it("pause message - default to 1 second") {
                let script = "pause"
                let ctx:MessageTestContext<PauseMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("pause"))
                expect(ctx.message.seconds).to(equal(1))
            }
            
            it("put message") {
                let script = "put #var something"
                let ctx:MessageTestContext<PutMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("put"))
                expect(ctx.message.message).to(equal("#var something"))
            }
            
            it("random message") {
                let script = "random 1 100"
                let ctx:MessageTestContext<RandomMessage> = self.buildMessage(script)
                
                expect(ctx.message.name).to(equal("random"))
                expect(ctx.message.min).to(equal(1))
                expect(ctx.message.max).to(equal(100))
            }
            
            it("save message") {
                let script = "save $something"
                let vars = { () -> [String:String] in
                    let res:[String:String] = ["something":"abcd"]
                    return res
                }
                let ctx:MessageTestContext<SaveMessage> = self.buildMessage(script, vars)
                
                expect(ctx.message.name).to(equal("save"))
                expect(ctx.message.text).to(equal("abcd"))
            }
            
            it("send message") {
                let script = "send echo $something"
                let vars = { () -> [String:String] in
                    let res:[String:String] = ["something":"abcd"]
                    return res
                }
                let ctx:MessageTestContext<SendMessage> = self.buildMessage(script, vars)
                
                expect(ctx.message.name).to(equal("send"))
                expect(ctx.message.message).to(equal("echo abcd"))
            }
            
            it("unar message") {
                let script = "unvar myvar"
                let ctx:MessageTestContext<UnVarMessage> = self.buildMessage(script, nil)
                
                expect(ctx.message.name).to(equal("unvar"))
                expect(ctx.message.identifier).to(equal("myvar"))
            }
            
        }
    }
    
}