//
//  EchoCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 5/4/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class EchoCommandHandler : CommandHandler {
    
    private var relay:CommandRelay
    
    class func newInstance(relay:CommandRelay) -> EchoCommandHandler {
        return EchoCommandHandler(relay)
    }
    
    init(_ relay:CommandRelay) {
        self.relay = relay
    }
    
    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#echo")
    }
    
    func handle(command: String, withContext: GameContext) {
        let echo = command.substringFromIndex(advance(command.startIndex, 5)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var groups = echo["^(>(\\w+)\\s)?((#[a-fA-F0-9]+)(,(#[a-fA-F0-9]+))?\\s)?(.*)"].groups()
        
        var window = groups[2]
        var foregroundColor = groups[4]
        var backgroundColor = groups[6]
        var text = groups[7]
        
        window = window == "_" ? "" : window
        foregroundColor = foregroundColor == "_" ? "" : foregroundColor
        backgroundColor = backgroundColor == "_" ? "" : backgroundColor
        text = text == "_" ? "" : text
        
        var tag = TextTag()
        tag.text = "\(text)\n"
        tag.color = foregroundColor
        tag.backgroundColor = backgroundColor
        tag.targetWindow = window.lowercaseString
        self.relay.sendEcho(tag)
    }
}