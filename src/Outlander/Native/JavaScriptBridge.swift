//
//  ReactBridge.swift
//  Outlander
//
//  Created by Joseph McBride on 6/25/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation
import JavaScriptCore

class JavaScriptExecutor {

    private let context:JSContext

    init() {
        self.context = JSContext()

        context.exceptionHandler = { context, exception in
            print("JS Error: \(exception)")
        }

        let nativeCallback: @convention(block) (AnyObject, AnyObject, [AnyObject]) -> Void = { (module, method, arguments) in
            print("nativeCallback: \(module) / \(method) / \(arguments)")
        }
        self.context.setObject(unsafeBitCast(nativeCallback, AnyObject.self), forKeyedSubscript: "nativeCallback")

        let log: @convention(block) [AnyObject] -> Void = { input in
            print("log: \(input)")
        }
        self.context.setObject(unsafeBitCast(log, AnyObject.self), forKeyedSubscript: "log2")
    }

    func evaluate(script:String) -> JSValue {
        return self.context.evaluateScript(script)
    }

    func callFunctionOnModule(module:String, method:String, arguments:[AnyObject]) -> JSValue {
        let bridge = self.context.objectForKeyedSubscript("Bridge")
        let fn = bridge.objectForKeyedSubscript("callFunction")
        return fn.callWithArguments([module, method, arguments])
    }
}

class JavaScriptBridge {

    private let executor:JavaScriptExecutor

    init() {
        self.executor = JavaScriptExecutor()
    }

    func loadApplication(script:String) {
        self.executor.evaluate(script)
    }
}
