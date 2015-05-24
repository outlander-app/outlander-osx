//
//  TestCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 5/24/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class TestCommandHandler : CommandHandler {
    
    class func newInstance() -> TestCommandHandler {
        return TestCommandHandler()
    }
    
    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#test")
    }
    
    func handle(command: String, withContext: GameContext) {
        NSBeep()
    }
}