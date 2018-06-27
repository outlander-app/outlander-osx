//
//  JavaScriptBridgeTester.swift
//  Outlander
//
//  Created by Joseph McBride on 6/26/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Cocoa
import Quick
import Nimble

class JavaScriptBridgeTester: QuickSpec {

    override func spec() {
        describe("bridge", {

            it("modules") {
                do {
                    let script = try String(contentsOfFile: "/Users/jomc/Documents/Dev/outlander-master/src/app/core/Bridge.js")
                    let exe = JavaScriptExecutor()
                    exe.evaluate(script)
                    let result = exe.callFunctionOnModule("math", method: "add", arguments: [1,2])
                    print(result)
                    expect(result.toInt32()).to(equal(3))
                } catch let error {
                    expect(error).to(beNil())
                }
            }

            it("module - global window?") {
                do {
                    let script = try String(contentsOfFile: "/Users/jomc/Documents/Dev/outlander-master/src/app/core/Bridge.js")
                    let exe = JavaScriptExecutor()
                    exe.evaluate(script)
                    let result = exe.callFunctionOnModule("win", method: "get", arguments: [])
                    print(result)
                } catch let error {
                    expect(error).to(beNil())
                }
            }
        })
    }
}
