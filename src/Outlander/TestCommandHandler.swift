//
//  TestCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 5/24/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class TestCommandHandler : NSObject, CommandHandler {
    
    class func newInstance() -> TestCommandHandler {
        return TestCommandHandler()
    }
    
    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#test")
    }
    
    func handle(_ command: String, with withContext: GameContext) {
        NSBeep()
    }
}
