//
//  ParserTests.swift
//  Outlander
//
//  Created by Joseph McBride on 4/4/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation
import Nimble
import Quick

class RecordingNotifier : INotifyMessage {

    var messages:[String] = []

    func notify(_ message:TextTag) {

        if message.text.contains("Starting") {
            return
        }

        if message.text.contains("started") {
            return
        }

        if message.text.contains("completed after") {
            return
        }

        if message.text.contains("initialized") {
            return
        }

        self.messages.append(message.text)
    }

    func sendCommand(_ command:CommandContext) {
        self.messages.append(command.command)
    }

    func sendEcho(_ echo:String) {
        self.messages.append(echo)
    }

    func clear() {
        messages.removeAll()
    }
}

class StubScriptLoader {
    var script:[String] = []

    func load() -> [String] {
        return script
    }

    func set(_ text:String) {
        script = text.components(separatedBy: "\n")
    }

    func set(_ lines:[String]) {
        script = lines
    }
}

class ScriptTester : QuickSpec {

    override func spec() {

        describe("the script") {

            let context = GameContext()
            let loader = StubScriptLoader()
            let notifier = RecordingNotifier()
            var script = try! Script(
                notifier,
                {_ in loader.load()},
                "Script",
                context,
                { print("done") })

            beforeEach() {
                notifier.clear()
                script = try! Script(
                    notifier,
                    {_ in loader.load()},
                    "Script",
                    context,
                    { print("done") })
            }

            describe("debug") {
                it("basic debug") {
                    loader.set("debug 5")
                    script.run([])
                    expect(notifier.messages).to(equal(["debug 5\n"]))
                }
            }

            describe("echo") {
                it("basic text") {
                    loader.set("echo hi")
                    script.run([])
                    expect(notifier.messages).to(equal(["hi"]))
                }
            }

            describe("if") {
                it("nested ifs") {
                    loader.set([
                        "if_1 {",
                            "echo one",
                            "if 1 == 1 {",
                                "echo two",
                            "}",
                            "echo after",
                        "}"
                    ])
                    script.run(["abcd"])
                    expect(notifier.messages).to(equal([
                        "one",
                        "two",
                        "after"
                    ]))
                }
            }

            describe("if else") {
                it("single line if else") {
                    loader.set([
                        "if 1 == 2 then echo one",
                        "else echo two"
                    ])
                    script.run([])
                    expect(notifier.messages).to(equal(["two"]))
                }

                it("single line if else") {
                    loader.set([
                        "if 1 == 1 then echo one",
                        "else echo two"
                    ])
                    script.run([])
                    expect(notifier.messages).to(equal(["one"]))
                }

                it("multi line else") {
                    loader.set([
                        "if 1 > 1 {",
                            "echo one",
                            "echo five",
                        "}",
                        "else",
                        "{",
                            "echo two",
                            "echo three",
                        "}"
                    ])
                    script.run([])
                    expect(notifier.messages).to(equal(["two", "three"]))
                }

                it("multi line else") {
                    loader.set([
                        "if 1 > 1 then echo one",
                        "else",
                        "{",
                        "echo two",
                        "echo three",
                        "}"
                    ])
                    script.run([])
                    expect(notifier.messages).to(equal(["two", "three"]))
                }

                it("multi line else") {
                    loader.set([
                        "if 1 > 1",
                        "{",
                            "echo one",
                            "echo five",
                        "}",
                        "else {",
                            "echo two",
                            "echo three",
                        "}"
                    ])
                    script.run([])
                    expect(notifier.messages).to(equal(["two", "three"]))
                }
            }
        }
    }
}
