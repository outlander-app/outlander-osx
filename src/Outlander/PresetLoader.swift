//
//  PresetLoader.swift
//  Outlander
//
//  Created by Joseph McBride on 1/20/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

@objc
class PresetLoader : NSObject {

    class func newInstance(_ context:GameContext, fileSystem:FileSystem) -> PresetLoader {
        return PresetLoader(context: context, fileSystem: fileSystem)
    }

    var context:GameContext
    var fileSystem:FileSystem

    init(context:GameContext, fileSystem:FileSystem) {
        self.context = context
        self.fileSystem = fileSystem
    }

    func load() {
        let configFile = self.context.pathProvider.profileFolder().stringByAppendingPathComponent("presets.cfg")

        if !self.fileSystem.fileExists(configFile) {
            setupDefaults()
            return
        }

        var data:String?

        do {
            data = try self.fileSystem.string(withContentsOfFile: configFile, encoding: String.Encoding.utf8.rawValue)
        } catch {
            return
        }

        if data == nil || data?.characters.count == 0 {
            return
        }

        self.context.presets.removeAll()

        let pattern = "^#preset \\{(.*?)\\} \\{(.*?)\\}(?:\\s\\{(.*?)\\})?$"

        let target = SwiftRegex(target: NSMutableString(string:data!), pattern: pattern, options: [NSRegularExpression.Options.anchorsMatchLines, NSRegularExpression.Options.caseInsensitive])

        let groups = target.allGroups()

        for group in groups {
            if group.count == 4 {
                let name = group[1]!
                var color = group[2]!
                var backgroundColor = ""
                var className = ""

                if group[3] != nil {
                    className = group[3]!
                }

                var colors = color.components(separatedBy: ",")

                if(colors.count > 1) {
                    color = colors[0]
                    backgroundColor = colors[1]
                }

                let item = ColorPreset(name, color, className)
                item.backgroundColor = backgroundColor

                self.context.presets[item.name] = item
            }
        }
    }

    func save() {
        let configFile = self.context.pathProvider.profileFolder().stringByAppendingPathComponent("presets.cfg")

        var presets = ""

        let sorted = context.presets.sorted { $0.0 < $1.0 }

        for (preset) in sorted {
            let name = preset.1.name
            let foreColor = preset.1.color
            let backgroundColor = preset.1.backgroundColor != nil ? preset.1.backgroundColor! : ""
            let className = preset.1.presetClass != nil ? preset.1.presetClass! : ""

            var color = foreColor

            if backgroundColor.characters.count > 0 {
                color = "\(color),\(backgroundColor)"
            }

            presets += "#preset {\(name)} {\(color)}"

            if className.characters.count > 0 {
                presets += " {\(className)}"
            }
            presets += "\n"
        }

        self.fileSystem.write(presets, toFile: configFile)
    }

    func setupDefaults() {
        self.add("automapper", "#99FFFF")
        self.add("chatter", "#99FFFF")
        self.add("creatures", "#FFFF00")
        self.add("roomdesc", "#cccccc")
        self.add("roomname", "#0000FF")
        self.add("scriptecho", "#99FFFF")
        self.add("scripterror", "#efefef", "#ff3300")
        self.add("scriptinfo", "#0066cc")
        self.add("scriptinput", "#acff2f")
        self.add("sendinput", "#acff2f")
        self.add("speech", "#99FFFF")
        self.add("thought", "#99FFFF")
        self.add("whisper", "#99FFFF")
    }

    func add(_ name:String, _ color:String, _ backgroundColor:String? = nil) {
        let preset = ColorPreset(name, color, backgroundColor ?? "", "")
        self.context.presets[name] = preset
    }
}
