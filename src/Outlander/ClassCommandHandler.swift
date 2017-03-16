//
//  ClassCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 3/14/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

class ClassCommandHandler : NSObject, CommandHandler {
    
    private var relay:CommandRelay
    
    class func newInstance(relay:CommandRelay) -> ClassCommandHandler {
        return ClassCommandHandler(relay)
    }
    
    init(_ relay:CommandRelay) {
        self.relay = relay
    }
    
    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#class")
    }
    
    func handle(command: String, withContext: GameContext) {

        let cmd = command
            .substringFromIndex(command.startIndex.advancedBy(6))
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        if cmd.hasPrefix("clear") {
            withContext.classSettings.clear()
            withContext.events.echoText("Classes cleared")
            return
        }

        if cmd.hasPrefix("load") {
            let loader = ClassesLoader(context: withContext, fileSystem: LocalFileSystem())
            loader.load()
            withContext.events.echoText("Classes reloaded")
            return
        }

        if cmd.hasPrefix("save") {
            let loader = ClassesLoader(context: withContext, fileSystem: LocalFileSystem())
            loader.save()
            withContext.events.echoText("Classes saved")
            return
        }

        if cmd.hasPrefix("list") {
            withContext.events.echoText("")
            withContext.events.echoText("Classes:")
            for c in withContext.classSettings.all() {
                let val = c.value ? "on" : "off"
                withContext.events.echoText("\(c.key): \(val)")
            }
            withContext.events.echoText("")
            return
        }

        withContext.classSettings.parse(cmd)
    }
}
