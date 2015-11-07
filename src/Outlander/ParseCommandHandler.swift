//
//  ParseCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/15/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class ParseCommandHandler : NSObject, CommandHandler {
    
    class func newInstance() -> ParseCommandHandler {
        return ParseCommandHandler()
    }
    
    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#parse")
    }
    
    func handle(command: String, withContext: GameContext) {
        let text = command
            .substringFromIndex(command.startIndex.advancedBy(6))
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let dict = ["text": text]
        
        withContext.events.publish("ol:game-parse", data: dict)
    }
}