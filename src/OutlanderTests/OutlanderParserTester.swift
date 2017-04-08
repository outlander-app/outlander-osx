//
//  OutlanderParserTester.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation
import Nimble
import Quick

class OutlanderParserTester : QuickSpec {

    override func spec() {

        describe("the parser") {

            beforeEach() {
            }

            it("parses a comment") {
                let result = ScriptParser().parse("\n#  onetwo:  \n\n")
                expect(result).toNot(beNil())

                if case .comment(let data) = result! {
                    expect(data).to(equal("  onetwo:"))
                } else {
                    fail("expected comment result")
                }
            }

            it("parses a comment") {
                let result = ScriptParser().parse("\n#echo")
                expect(result).toNot(beNil())

                if case .comment(let data) = result! {
                    expect(data).to(equal("echo"))
                } else {
                    fail("expected comment result")
                }
            }

            it("parses a label") {
                let result = ScriptParser().parse("\n  onetwo:  \n\n")
                expect(result).toNot(beNil())

                if case .label(let data) = result! {
                    expect(data).to(equal("onetwo"))
                } else {
                    fail("expected label result")
                }
            }

            it("parses put") {
                let result = ScriptParser().parse("\n  put one two  \n\n")
                expect(result).toNot(beNil())

                if case .put(let data) = result! {
                    expect(data).to(equal("one two"))
                } else {
                    fail("expected put result")
                }
            }

            it("does not parse put") {
                let result = ScriptParser().parse("\n  putone two  \n\n")
                expect(result).to(beNil())
            }

            it("parses pause") {
                let result = ScriptParser().parse("\n  pause  \n\n")
                expect(result).toNot(beNil())

                if case .pause(let time) = result! {
                    expect(time).to(equal(1))
                } else {
                    fail("expected pause result")
                }
            }

            it("parses pause with number") {
                let result = ScriptParser().parse("\n  pause 3  \n\n")
                expect(result).toNot(beNil())

                if case .pause(let time) = result! {
                    expect(time).to(equal(3))
                } else {
                    fail("expected pause result")
                }
            }

            it("parses pause with fraction") {
                let result = ScriptParser().parse("\n  pause 0.5  \n\n")
                expect(result).toNot(beNil())

                if case .pause(let time) = result! {
                    expect(time).to(equal(0.5))
                } else {
                    fail("expected pause result")
                }
            }

            it("parses echo") {
                let result = ScriptParser().parse("\n echo  \n\necho two")
                expect(result).toNot(beNil())
                
                if case .echo(let text) = result! {
                    expect(text).to(equal(""))
                } else {
                    fail("expected echo result")
                }
            }

            it("parses echo") {
                let result = ScriptParser().parse("\n echo abcd \n\n")
                expect(result).toNot(beNil())
                
                if case .echo(let text) = result! {
                    expect(text).to(equal("abcd"))
                } else {
                    fail("expected echo result")
                }
            }

            it("parses ECHO") {
                let result = ScriptParser().parse("ECHO Hello World \n\n")
                expect(result).toNot(beNil())
                
                if case .echo(let text) = result! {
                    expect(text).to(equal("Hello World"))
                } else {
                    fail("expected echo result")
                }
            }

            it("parses echo with leading spaces") {
                let result = ScriptParser().parse("\n echo  abcd \n\n")
                expect(result).toNot(beNil())
                
                if case .echo(let text) = result! {
                    expect(text).to(equal(" abcd"))
                } else {
                    fail("expected echo result")
                }
            }

            it("does not parse echo") {
                let result = ScriptParser().parse("\n echoabcd \n\n")
                expect(result).to(beNil())
            }

            it("parses goto") {
                let result = ScriptParser().parse("\n goto one \n\n")
                expect(result).toNot(beNil())
                
                if case .goto(let label) = result! {
                    expect(label).to(equal("one"))
                } else {
                    fail("expected goto result")
                }
            }

            it("parses goto with variable") {
                let result = ScriptParser().parse("\n goto %one \n\n")
                expect(result).toNot(beNil())
                
                if case .goto(let label) = result! {
                    expect(label).to(equal("%one"))
                } else {
                    fail("expected goto result")
                }
            }

            it("parses exit") {
                let result = ScriptParser().parse("\n exit \n\n")
                expect(result).toNot(beNil())
            }

            it("parses debug with value") {
                let result = ScriptParser().parse("\n debug 5 \n\n")
                expect(result).toNot(beNil())

                if case .debug(let level) = result! {
                    expect(level).to(equal(5))
                } else {
                    fail("expected debug result")
                }
            }

            it("parses difference case debug") {
                let result = ScriptParser().parse("\n DEBUG 5 \n\n")
                expect(result).toNot(beNil())
                
                if case .debug(let level) = result! {
                    expect(level).to(equal(5))
                } else {
                    fail("expected debug result")
                }
            }

            it("parses difference case debug") {
                let result = ScriptParser().parse("\n Debug 5 \n\n")
                expect(result).toNot(beNil())
                
                if case .debug(let level) = result! {
                    expect(level).to(equal(5))
                } else {
                    fail("expected debug result")
                }
            }

            it("parses difference case debug") {
                let result = ScriptParser().parse("\n dEbUG 5 \n\n")
                expect(result).toNot(beNil())
                
                if case .debug(let level) = result! {
                    expect(level).to(equal(5))
                } else {
                    fail("expected debug result")
                }
            }

            it("parses if_x single line") {
                let result = ScriptParser().parse("\n if_1 then put hello \n\n")
                expect(result).toNot(beNil())
                
                if case .ifArgSingle(let arg, let token) = result! {
                    expect(arg).to(equal(1))

                    if case .put(let text) = token {
                        expect(text).to(equal("hello"))
                    } else {
                        fail("expected put result")
                    }
                    
                } else {
                    fail("expected if_x single line result")
                }
            }

            it("parses if_x multi line") {
                guard let result = ScriptParser().parse("\n if_1 { \n\n") else {
                    fail("expected if line result")
                    return
                }

                if case .ifArg(let arg) = result {
                    expect(arg).to(equal(1))
                } else {
                    fail("expected if_x result")
                }
            }

            it("parses if_x multi line") {
                guard let result = ScriptParser().parse("\n if_1{ \n\n") else {
                    fail("expected if line result")
                    return
                }

                if case .ifArg(let arg) = result {
                    expect(arg).to(equal(1))
                } else {
                    fail("expected if_x result")
                }
            }

            it("parses if_x multi line") {
                guard let result = ScriptParser().parse("\n if_1 then { \n\n") else {
                    fail("expected if line result")
                    return
                }

                if case .ifArg(let arg) = result {
                    expect(arg).to(equal(1))
                } else {
                    fail("expected if_x result")
                }
            }

            it("parses if_x multi line") {
                guard let result = ScriptParser().parse("\n if_1  then  { \n\n") else {
                    fail("expected if line result")
                    return
                }

                if case .ifArg(let arg) = result {
                    expect(arg).to(equal(1))
                } else {
                    fail("expected if_x result")
                }
            }

            it("parses if_x multi line") {
                let result = ScriptParser().parse("\n if_1then  { \n\n")
                expect(result).to(beNil())
            }

            it("parses if single line") {
                guard let result = ScriptParser().parse("\n if abcd then put hello \n\n") else {
                    fail("expected if single line result")
                    return
                }
                
                if case .ifSingle(let exp, let token) = result {
                    expect(exp).to(equal("abcd"))

                    if case .put(let text) = token {
                        expect(text).to(equal("hello"))
                    } else {
                        fail("expected put result")
                    }
                    
                } else {
                    fail("expected if single line result")
                }
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if abcd { \n\n") else {
                    fail("expected if line result")
                    return
                }

                if case .If(let exp) = result {
                    expect(exp).to(equal("abcd"))
                } else {
                    fail("expected if line result")
                }
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if abcd \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .ifNeedsBrace(let exp) = result {
                    expect(exp).to(equal("abcd"))
                } else {
                    fail("expected if line result")
                }
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if abcd then { \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .If(let exp) = result {
                    expect(exp).to(equal("abcd"))
                } else {
                    fail("expected if line result")
                }
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if  abcd  then{ \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .If(let exp) = result {
                    expect(exp).to(equal("abcd"))
                } else {
                    fail("expected if line result")
                }
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if abcd{ \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .If(let exp) = result {
                    expect(exp).to(equal("abcd"))
                } else {
                    fail("expected if line result")
                }
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if %one >= $then.LearningRate { \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .If(let exp) = result {
                    expect(exp).to(equal("%one >= $then.LearningRate"))
                } else {
                    fail("expected if line result")
                }
            }

            it("parses if multi line - stuff after brace") {
                let result = ScriptParser().parse("\n if abcd then { aslkdjfasf \n\n")
                expect(result).to(beNil())
            }

            it("parses if multi line - then no brace") {
                guard let result = ScriptParser().parse("\n if %one >= $then.LearningRate then \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .ifNeedsBrace(let exp) = result {
                    expect(exp).to(equal("%one >= $then.LearningRate"))
                } else {
                    fail("expected if line result")
                }
            }

            it("parses if multi line - no then no brace") {
                guard let result = ScriptParser().parse("\n if %one >= $then.LearningRate \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .ifNeedsBrace(let exp) = result {
                    expect(exp).to(equal("%one >= $then.LearningRate"))
                } else {
                    fail("expected if line result")
                }
            }

            it("parses else if single line") {
                guard let result = ScriptParser().parse("\n else if abcd then put hello \n\n") else {
                    fail("expected else if single line result")
                    return
                }
                
                if case .elseIfSingle(let exp, let token) = result {
                    expect(exp).to(equal("abcd"))

                    if case .put(let text) = token {
                        expect(text).to(equal("hello"))
                    } else {
                        fail("expected put result")
                    }
                    
                } else {
                    fail("expected else if single line result")
                }
            }

            it("parses else if multi line - no then no brace") {
                guard let result = ScriptParser().parse("\n else if %one >= $then.LearningRate \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .elseIfNeedsBrace(let exp) = result {
                    expect(exp).to(equal("%one >= $then.LearningRate"))
                } else {
                    fail("expected else if line result")
                }
            }

            it("parses else if multi line - brace") {
                guard let result = ScriptParser().parse("\n else if %one >= $then.LearningRate {\n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .elseIf(let exp) = result {
                    expect(exp).to(equal("%one >= $then.LearningRate"))
                } else {
                    fail("expected else if line result")
                }
            }

            it("parses else if multi line - then brace") {
                guard let result = ScriptParser().parse("\n else if %one >= $then.LearningRate then {\n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .elseIf(let exp) = result {
                    expect(exp).to(equal("%one >= $then.LearningRate"))
                } else {
                    fail("expected else if line result")
                }
            }

            it("parses else if multi line - then") {
                guard let result = ScriptParser().parse("\n else if %one >= $then.LearningRate then\n\n") else {
                    fail("expected if line result")
                    return
                }
                
                if case .elseIfNeedsBrace(let exp) = result {
                    expect(exp).to(equal("%one >= $then.LearningRate"))
                } else {
                    fail("expected else if line result")
                }
            }

            it("parses else single") {
                guard let result = ScriptParser().parse("\n else put hello \n\n") else {
                    fail("expected else line result")
                    return
                }

                if case .elseSingle(let token) = result {
                    if case .put(let text) = token {
                        expect(text).to(equal("hello"))
                    } else {
                        fail("expected put result")
                    }
                } else {
                    fail("expected else single line result")
                }
            }

            it("parses else multi line - no brace") {
                guard let result = ScriptParser().parse("\n else \n\n") else {
                    fail("expected else line result")
                    return
                }

                guard case .elseNeedsBrace = result else {
                    fail("expected else line result")
                    return
                }
            }

            it("parses else multi line - with brace") {
                guard let result = ScriptParser().parse("\n else {\n\n") else {
                    fail("expected else line result")
                    return
                }

                guard case .Else = result else {
                    fail("expected else line result")
                    return
                }
            }

            it("parses var") {
                let result = ScriptParser().parse("\n var one two \n\n")
                expect(result).toNot(beNil())
                
                if case .variable(let key, let value) = result! {
                    expect(key).to(equal("one"))
                    expect(value).to(equal("two"))
                } else {
                    fail("expected variable result")
                }
            }

            it("parses var") {
                let result = ScriptParser().parse("\n var one.two two \n\n")
                expect(result).toNot(beNil())

                if case .variable(let key, let value) = result! {
                    expect(key).to(equal("one.two"))
                    expect(value).to(equal("two"))
                } else {
                    fail("expected variable result")
                }
            }

            it("parses setvariable") {
                let result = ScriptParser().parse("\n setvariable one two \n\n")
                expect(result).toNot(beNil())
                
                if case .variable(let key, let value) = result! {
                    expect(key).to(equal("one"))
                    expect(value).to(equal("two"))
                } else {
                    fail("expected variable result")
                }
            }

            it("parses var without value") {
                let result = ScriptParser().parse("\n var one \n\n")
                expect(result).toNot(beNil())
                
                if case .variable(let key, let value) = result! {
                    expect(key).to(equal("one"))
                    expect(value).to(equal(""))
                } else {
                    fail("expected variable result")
                }
            }

            it("parses left brace {") {
                let result = ScriptParser().parse("\n { \n\n")
                expect(result).toNot(beNil())
                
                if case .token(let token) = result! {
                    expect(token).to(equal("{"))
                } else {
                    fail("expected {")
                }
            }

            it("parses right brace }") {
                let result = ScriptParser().parse("\n } \n\n")
                expect(result).toNot(beNil())
                
                if case .token(let token) = result! {
                    expect(token).to(equal("}"))
                } else {
                    fail("expected }")
                }
            }
        }
    }
}
