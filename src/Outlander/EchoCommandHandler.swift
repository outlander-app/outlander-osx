//
//  EchoCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 5/4/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class EchoCommandHandler : NSObject, CommandHandler {
    
    fileprivate var relay:CommandRelay
    
    class func newInstance(_ relay:CommandRelay) -> EchoCommandHandler {
        return EchoCommandHandler(relay)
    }
    
    init(_ relay:CommandRelay) {
        self.relay = relay
    }
    
    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#echo")
    }
    
    func handle(_ command: String, with withContext: GameContext) {
        let echo = command
            .substring(from: command.characters.index(command.startIndex, offsetBy: 5))
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        var groups = echo["^(>(\\w+)\\s)?((#[a-fA-F0-9]+)(,(#[a-fA-F0-9]+))?\\s)?(.*)"].allGroups().first!
        
        var window = groups[2]
        var foregroundColor = groups[4]
        var backgroundColor = groups[6]
        var text = groups[7]
        
        window = window == nil ? "" : window
        foregroundColor = foregroundColor == nil ? "" : foregroundColor
        backgroundColor = backgroundColor == nil ? "" : backgroundColor
        text = text == nil ? "" : text
        
        let tag = TextTag()
        tag.text = "\(text!)\n"
        tag.color = foregroundColor!
        tag.backgroundColor = backgroundColor!
        tag.targetWindow = window!.lowercased()
        self.relay.sendEcho(tag)
    }
}
