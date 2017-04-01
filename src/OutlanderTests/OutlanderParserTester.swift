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
                    fail("expected level result")
                }
            }
        }
    }
}
