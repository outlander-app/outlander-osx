//
//  WindowCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 5/19/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class WindowCommandHandler : NSObject, CommandHandler {
    
    class func newInstance() -> WindowCommandHandler {
        return WindowCommandHandler()
    }
    
    let validCommands = ["add", "clear", "hide", "list", "reload", "show"]
    
    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#window")
    }
    
    func handle(_ command: String, with withContext: GameContext) {
        
        let commands = command
            .substring(from: command.characters.index(command.startIndex, offsetBy: 7))
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if commands.hasPrefix("reload") {
            let loader = WindowDataService()
            let layout = loader.readLayoutJson(withContext)
            withContext.layout = layout
            withContext.events.publish("OL:window", data: ["action":"reload" as AnyObject, "window":"" as AnyObject])
            return
        }

        let groups = commands["(.*) (.*)"].allGroups().first!

        if groups.count > 2 && validCommands.contains(groups[1]!) {
            let action = groups[1]!.lowercased()
            let window = groups[2]!.lowercased()

            withContext.events.publish("OL:window", data: ["action":action as AnyObject, "window":window as AnyObject])
        }
    }
}
