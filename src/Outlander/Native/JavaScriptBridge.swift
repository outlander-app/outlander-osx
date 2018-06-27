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

        let nativeCallback: @convention(block) (String, String, [AnyObject]) -> Void = { (module, method, arguments) in
            print("\(module) / \(method) / \(arguments)")
        }
        self.context.setObject(unsafeBitCast(nativeCallback, AnyObject.self), forKeyedSubscript: "nativeCallback")
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
