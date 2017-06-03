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
    
    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#parse")
    }
    
    func handle(_ command: String, with withContext: GameContext) {
        let text = command
            .substring(from: command.characters.index(command.startIndex, offsetBy: 6))
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let dict:[String:AnyObject] = ["text": text as AnyObject]

        withContext.events.publish("ol:game-parse", data: dict)
    }
}
