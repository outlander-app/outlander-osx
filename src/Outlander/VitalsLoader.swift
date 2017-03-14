//
//  VitalsLoader.swift
//  Outlander
//
//  Created by Joseph McBride on 3/13/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

@objc
class VitalsLoader : NSObject {
    
    class func newInstance(context:GameContext, fileSystem:FileSystem) -> VitalsLoader {
        return VitalsLoader(context: context, fileSystem: fileSystem)
    }
    
    var context:GameContext
    var fileSystem:FileSystem

    init(context:GameContext, fileSystem:FileSystem) {
        self.context = context
        self.fileSystem = fileSystem
    }
    
    func load() {
        let configFile = self.context.pathProvider.profileFolder().stringByAppendingPathComponent("vitals.cfg")

        if !self.fileSystem.fileExists(configFile) {
            context.vitalsSettings = VitalsSettings()
            return
        }

        var json:String?

        do {
            json = try self.fileSystem.stringWithContentsOfFile(configFile, encoding: NSUTF8StringEncoding)
        } catch {
            return
        }

        if json == nil {
            return
        }

        do {
            let dict = try JSONSerializer.toDictionary(json!)

            context.vitalsSettings.healthColor = dict.stringValue("healthColor", defaultVal: "#cc0000")
            context.vitalsSettings.healthTextColor = dict.stringValue("healthTextColor", defaultVal: "#f5f5f5")

            context.vitalsSettings.manaColor = dict.stringValue("manaColor", defaultVal: "#00004b")
            context.vitalsSettings.manaTextColor = dict.stringValue("manaTextColor", defaultVal: "#f5f5f5")
            
            context.vitalsSettings.staminaColor = dict.stringValue("staminaColor", defaultVal: "#004000")
            context.vitalsSettings.staminaTextColor = dict.stringValue("staminaTextColor", defaultVal: "#f5f5f5")
            
            context.vitalsSettings.concentrationColor = dict.stringValue("concentrationColor", defaultVal: "#009999")
            context.vitalsSettings.concentrationTextColor = dict.stringValue("concentrationTextColor", defaultVal: "#f5f5f5")
            
            context.vitalsSettings.spiritColor = dict.stringValue("spiritColor", defaultVal: "#400040")
            context.vitalsSettings.spiritTextColor = dict.stringValue("spiritTextColor", defaultVal: "#f5f5f5")
            
        } catch {
            return
        }
    }

    func save() {
        let configFile = self.context.pathProvider.profileFolder().stringByAppendingPathComponent("vitals.cfg")

        let json = JSONSerializer.toJson(context.vitalsSettings, prettify: true)

        self.fileSystem.write(json, toFile: configFile)
    }
}

extension NSDictionary {
    func stringValue(key:String, defaultVal:String = "") -> String {

        if let value = self[key] as? String {
            return value
        }

        return defaultVal
    }
}
