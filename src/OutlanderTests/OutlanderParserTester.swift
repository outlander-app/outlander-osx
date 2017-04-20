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

                guard case let .ifSingle(exp, token) = result else {
                    fail("expected if single line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("abcd"))

                if case .put(let text) = token {
                    expect(text).to(equal("hello"))
                } else {
                    fail("expected put result")
                }
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if abcd { \n\n") else {
                    fail("expected if line result")
                    return
                }

                guard case let .If(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("abcd"))
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if abcd \n\n") else {
                    fail("expected if line result")
                    return
                }

                guard case let .ifNeedsBrace(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("abcd"))
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if abcd then { \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                guard case let .If(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("abcd"))
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if  abcd  then{ \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                guard case let .If(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("abcd"))
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if abcd{ \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                guard case let .If(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("abcd"))
            }

            it("parses if multi line") {
                guard let result = ScriptParser().parse("\n if %one >= $then.LearningRate { \n\n") else {
                    fail("expected if line result")
                    return
                }
                
                guard case let .If(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("%one >= $then.LearningRate"))
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
                
                guard case let .ifNeedsBrace(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("%one >= $then.LearningRate"))
            }

            it("parses if multi line - no then no brace") {
                guard let result = ScriptParser().parse("\n if %one >= $then.LearningRate \n\n") else {
                    fail("expected if line result")
                    return
                }

                guard case let .ifNeedsBrace(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("%one >= $then.LearningRate"))
            }

            it("parses else if single line") {
                guard let result = ScriptParser().parse("\n else if abcd then put hello \n\n") else {
                    fail("expected else if single line result")
                    return
                }

                guard case let .elseIfSingle(exp, token) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("abcd"))

                guard case let .put(text) = token else {
                    fail("expected put result")
                    return
                }

                expect(text).to(equal("hello"))
            }

            it("parses else if multi line - no then no brace") {
                guard let result = ScriptParser().parse("\n else if %one >= $then.LearningRate \n\n") else {
                    fail("expected if line result")
                    return
                }

                guard case let .elseIfNeedsBrace(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("%one >= $then.LearningRate"))
            }

            it("parses else if multi line - brace") {
                guard let result = ScriptParser().parse("\n else if %one >= $then.LearningRate {\n\n") else {
                    fail("expected if line result")
                    return
                }
                
                guard case let .elseIf(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("%one >= $then.LearningRate"))
            }

            it("parses else if multi line - then brace") {
                guard let result = ScriptParser().parse("\n else if %one >= $then.LearningRate then {\n\n") else {
                    fail("expected if line result")
                    return
                }
                
                guard case let .elseIf(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("%one >= $then.LearningRate"))
            }

            it("parses else if multi line - then") {
                guard let result = ScriptParser().parse("\n else if %one >= $then.LearningRate then\n\n") else {
                    fail("expected if line result")
                    return
                }
                
                guard case let .elseIfNeedsBrace(exp) = result else {
                    fail("expected if line result")
                    return
                }

                guard case let .value(val) = exp else {
                    fail("expected value expression result")
                    return
                }

                expect(val).to(equal("%one >= $then.LearningRate"))
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

        describe("gosub") {
            it("basic") {
                guard let result = ScriptParser().parse("\n gosub one three four\n\n") else {
                    fail("expected gosub result")
                    return
                }

                guard case let .gosub(label, args) = result else {
                    fail("expected gosub result")
                    return
                }

                expect(label).to(equal("one"))
                expect(args).to(equal("three four"))
            }
            
            it("zero arguments") {
                guard let result = ScriptParser().parse("gosub one") else {
                    fail("expected gosub result")
                    return
                }

                guard case let .gosub(label, args) = result else {
                    fail("expected gosub result")
                    return
                }

                expect(label).to(equal("one"))
                expect(args).to(equal(""))
            }

            it("variable for label") {
                guard let result = ScriptParser().parse("\n gosub %one.two three four\n\n") else {
                    fail("expected gosub result")
                    return
                }

                guard case let .gosub(label, args) = result else {
                    fail("expected gosub result")
                    return
                }

                expect(label).to(equal("%one.two"))
                expect(args).to(equal("three four"))
            }
        }

        describe("match") {
            it("basic") {
                guard let result = ScriptParser().parse("\n match one abcd \n\n") else {
                    fail("expected match line result")
                    return
                }

                guard case let .match(label, val) = result else {
                    fail("expected match line result")
                    return
                }

                expect(label).to(equal("one"))
                expect(val).to(equal("abcd"))
            }

            it("basic") {
                guard let result = ScriptParser().parse("\n match one.two abcd 12345 asldfkj \n\n") else {
                    fail("expected match line result")
                    return
                }

                guard case let .match(label, val) = result else {
                    fail("expected match line result")
                    return
                }

                expect(label).to(equal("one.two"))
                expect(val).to(equal("abcd 12345 asldfkj"))
            }
        }

        describe("matchre") {
            it("basic") {
                guard let result = ScriptParser().parse("\n matchre one abcd|123 \n\n") else {
                    fail("expected match line result")
                    return
                }

                guard case let .matchre(label, val) = result else {
                    fail("expected match line result")
                    return
                }

                expect(label).to(equal("one"))
                expect(val).to(equal("abcd|123"))
            }

            it("basic") {
                guard let result = ScriptParser().parse("\n matchre one.two ^Stow what|^You must unload|^You get some \n\n") else {
                    fail("expected matchre line result")
                    return
                }

                guard case let .matchre(label, val) = result else {
                    fail("expected matchre line result")
                    return
                }

                expect(label).to(equal("one.two"))
                expect(val).to(equal("^Stow what|^You must unload|^You get some"))
            }
        }

        describe("random") {
            it("basic") {
                guard let result = ScriptParser().parse("\n random 1 2 \n\n") else {
                    fail("expected random line result")
                    return
                }

                guard case let .random(min, max) = result else {
                    fail("expected random line result")
                    return
                }

                expect(min).to(equal("1"))
                expect(max).to(equal("2"))
            }

            it("variables") {
                guard let result = ScriptParser().parse("\n random %one.two %three \n\n") else {
                    fail("expected random line result")
                    return
                }

                guard case let .random(min, max) = result else {
                    fail("expected random line result")
                    return
                }

                expect(min).to(equal("%one.two"))
                expect(max).to(equal("%three"))
            }

            it("one variable") {
                guard let result = ScriptParser().parse("\n random 3 %three \n\n") else {
                    fail("expected random line result")
                    return
                }

                guard case let .random(min, max) = result else {
                    fail("expected random line result")
                    return
                }

                expect(min).to(equal("3"))
                expect(max).to(equal("%three"))
            }
        }

        describe("functions") {
            it("quotes") {
                guard let (result, rest) = ScriptParser().quote().run("\"abcd one two\" rest") else {
                    fail("expected result")
                    return
                }
                expect(result).to(equal("\"abcd one two\""))
                expect(String(rest)).to(equal(" rest"))
            }

            it("quotes handles escapes") {
                guard let (result, rest) = ScriptParser().quote().run("\"abcd \\\"one two\" rest") else {
                    fail("expected result")
                    return
                }
                expect(result).to(equal("\"abcd \\\"one two\""))
                expect(String(rest)).to(equal(" rest"))
            }

            it("function args") {
                guard let (result, rest) = ScriptParser().functionArgs().run("\"abcd \\\"one two\", \"three four\", %one.two rest") else {
                    fail("expected result")
                    return
                }
                expect(result).to(equal(["\"abcd \\\"one two\"", "\"three four\"", "%one.two"]))
                expect(String(rest)).to(equal(" rest"))
            }

            it("contains") {
                guard let result = ScriptParser().parse("\n if contains(\"abcd\", \"three four\") { \n\n") else {
                    fail("expected if function line result")
                    return
                }

                guard case let .If(exp) = result else {
                    fail("expected if function line result")
                    return
                }

                guard case let .function(name, args) = exp else {
                    fail("expected function line result")
                    return
                }

                expect(name).to(equal("contains"))
                expect(args).to(equal("\"abcd\", \"three four\""))
            }

            it("matchre") {
                guard let result = ScriptParser().parse("\n if matchre(\"abcd\", \"three four\") { \n\n") else {
                    fail("expected if function line result")
                    return
                }

                guard case let .If(exp) = result else {
                    fail("expected if function line result")
                    return
                }

                guard case let .function(name, args) = exp else {
                    fail("expected function line result")
                    return
                }

                expect(name).to(equal("matchre"))
                expect(args).to(equal("\"abcd\", \"three four\""))
            }

            it("matchre with regex") {
                guard let result = ScriptParser().parse("\n if matchre  (\"%dir\", \"^(search|swim) \") { \n\n") else {
                    fail("expected if function line result")
                    return
                }

                guard case let .If(exp) = result else {
                    fail("expected if function line result")
                    return
                }

                guard case let .function(name, args) = exp else {
                    fail("expected function line result")
                    return
                }

                expect(name).to(equal("matchre"))
                expect(args).to(equal("\"%dir\", \"^(search|swim) \""))
            }

            it("matchre with regex and variable") {
                guard let result = ScriptParser().parse("\n if matchre( %dir,  \"^(search|swim) \"  ) { \n\n") else {
                    fail("expected if function line result")
                    return
                }

                guard case let .If(exp) = result else {
                    fail("expected if function line result")
                    return
                }

                guard case let .function(name, args) = exp else {
                    fail("expected function line result")
                    return
                }

                expect(name).to(equal("matchre"))
                expect(args).to(equal("%dir, \"^(search|swim) \""))
            }
        }

        describe("actions") {
            it("basic") {
                guard let result = ScriptParser().parse("\n action var one two when abcd \n\n") else {
                    fail("expected action line result")
                    return
                }

                guard case let .action(cls, cmd, pattern) = result else {
                    fail("expected action line result")
                    return
                }

                expect(cls).to(equal(""))
                expect(cmd).to(equal("var one two"))
                expect(pattern).to(equal("abcd"))
            }

            it("multi commands") {
                guard let result = ScriptParser().parse("\n action var one two;var three four when abcd \n\n") else {
                    fail("expected action line result")
                    return
                }

                guard case let .action(cls, cmd, pattern) = result else {
                    fail("expected action line result")
                    return
                }

                expect(cls).to(equal(""))
                expect(cmd).to(equal("var one two;var three four"))
                expect(pattern).to(equal("abcd"))
            }

            it("regex") {
                guard let result = ScriptParser().parse("action put #beep;put #flash when ^(.+) (say|says|asks|exlaims|whispers)") else {
                    fail("expected action line result")
                    return
                }

                guard case let .action(cls, cmd, pattern) = result else {
                    fail("expected action line result")
                    return
                }

                expect(cls).to(equal(""))
                expect(cmd).to(equal("put #beep;put #flash"))
                expect(pattern).to(equal("^(.+) (say|says|asks|exlaims|whispers)"))
            }

            it("regex with class") {
                guard let result = ScriptParser().parse("action (talk) put #beep;put #flash when ^(.+) (say|says|asks|exlaims|whispers)") else {
                    fail("expected action line result")
                    return
                }

                guard case let .action(cls, cmd, pattern) = result else {
                    fail("expected action line result")
                    return
                }

                expect(cls).to(equal("talk"))
                expect(cmd).to(equal("put #beep;put #flash"))
                expect(pattern).to(equal("^(.+) (say|says|asks|exlaims|whispers)"))
            }

            it("toggle on") {
                guard let result = ScriptParser().parse("action (talk) on") else {
                    fail("expected action line result")
                    return
                }

                guard case let .actionToggle(cls, toggle) = result else {
                    fail("expected action line result")
                    return
                }

                expect(cls).to(equal("talk"))
                expect(toggle).to(equal("on"))
            }

            it("toggle off") {
                guard let result = ScriptParser().parse("action (talk) off") else {
                    fail("expected action line result")
                    return
                }

                guard case let .actionToggle(cls, toggle) = result else {
                    fail("expected action line result")
                    return
                }

                expect(cls).to(equal("talk"))
                expect(toggle).to(equal("off"))
            }

            it("toggle variable") {
                guard let result = ScriptParser().parse("action (talk) %toggle") else {
                    fail("expected action line result")
                    return
                }

                guard case let .actionToggle(cls, toggle) = result else {
                    fail("expected action line result")
                    return
                }

                expect(cls).to(equal("talk"))
                expect(toggle).to(equal("%toggle"))
            }
        }
    }
}
