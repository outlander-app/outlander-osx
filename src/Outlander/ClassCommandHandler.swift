//
//  ClassCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 3/14/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

class ClassCommandHandler : NSObject, CommandHandler {
    
    fileprivate var relay:CommandRelay
    
    class func newInstance(_ relay:CommandRelay) -> ClassCommandHandler {
        return ClassCommandHandler(relay)
    }
    
    init(_ relay:CommandRelay) {
        self.relay = relay
    }
    
    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#class")
    }
    
    func handle(_ command: String, with withContext: GameContext) {

        let cmd = command
            .substring(from: command.characters.index(command.startIndex, offsetBy: 6))
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

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
