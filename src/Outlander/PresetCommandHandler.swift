//
//  PresetCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 1/24/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

@objc
class PresetCommandHandler : NSObject, CommandHandler {
    class func newInstance() -> PresetCommandHandler {
        return PresetCommandHandler()
    }

    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#preset")
    }

    func handle(_ command: String, with withContext: GameContext) {

        let text = command
            .substring(from: command.characters.index(command.startIndex, offsetBy: 7))
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        let options = text.components(separatedBy: " ")

        if options.count > 0 && options[0].lowercased() == "reload" {
            let loader = PresetLoader.newInstance(withContext, fileSystem: LocalFileSystem())
            loader.load()
            withContext.events.echoText("Preset colors reloaded", mono: true, preset: "")
            return
        }

        handleAddUpdate(options, context: withContext)
    }

    func handleAddUpdate(_ options: [String], context: GameContext) {
        guard options.count > 2 else {
            context.events.echoText("You must provide a preset name and value", mono: true, preset: "scripterror")
            return
        }

        let name = options[0]
        let foreColor = options[1]
        let backgroundColor = options.count > 2 ? options[2] : ""

        let presetColor = ColorPreset(name, foreColor, backgroundColor, "")

        if let found = context.presets[name] {
            found.color = foreColor
            if backgroundColor.characters.count > 0 {
                found.backgroundColor = backgroundColor
            }
        } else {
            context.presets[name] = presetColor
        }
    }
}
