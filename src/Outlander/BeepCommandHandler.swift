//
//  BeepCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/18/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class BeepCommandHandler : NSObject, CommandHandler {
    
    class func newInstance() -> BeepCommandHandler {
        return BeepCommandHandler()
    }
    
    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#beep")
    }
    
    func handle(_ command: String, with withContext: GameContext) {
        NSBeep()
    }
}

@objc
class FlashCommandHandler : NSObject, CommandHandler {
    
    class func newInstance() -> FlashCommandHandler {
        return FlashCommandHandler()
    }
    
    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#flash")
    }
    
    func handle(_ command: String, with withContext: GameContext) {
        NSApplication.shared().requestUserAttention(NSRequestUserAttentionType.criticalRequest)
    }
}
