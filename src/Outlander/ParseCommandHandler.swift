//
//  ParseCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/15/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class ParseCommandHandler : CommandHandler {
    
    class func newInstance() -> ParseCommandHandler {
        return ParseCommandHandler()
    }
    
    func canHandle(command: String) -> Bool {
        return command.hasPrefix("#parse")
    }
    
    func handle(command: String, withContext: GameContext) {
        let text = command.substringFromIndex(advance(command.startIndex, 6)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var dict = ["text": text]
        
        withContext.events.publish("ol:game-parse", data: dict)
    }
}