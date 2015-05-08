//
//  BeepCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/18/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class BeepCommandHandler : CommandHandler {
    
    class func newInstance() -> BeepCommandHandler {
        return BeepCommandHandler()
    }
    
    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#beep")
    }
    
    func handle(command: String, withContext: GameContext) {
        NSBeep()
    }
}

@objc
class FlashCommandHandler : CommandHandler {
    
    class func newInstance() -> FlashCommandHandler {
        return FlashCommandHandler()
    }
    
    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#flash")
    }
    
    func handle(command: String, withContext: GameContext) {
        NSApplication.sharedApplication().requestUserAttention(NSRequestUserAttentionType.CriticalRequest)
    }
}
