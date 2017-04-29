//
//  AppConfigLoader.swift
//  Outlander
//
//  Created by Joseph McBride on 3/19/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

@objc
class AppConfigLoader : NSObject {

    class func newInstance(context:GameContext, fileSystem:FileSystem) -> AppConfigLoader {
        return AppConfigLoader(context: context, fileSystem: fileSystem)
    }

    var context:GameContext
    var fileSystem:FileSystem

    init(context:GameContext, fileSystem:FileSystem) {
        self.context = context
        self.fileSystem = fileSystem
    }

    func load() {
        let configFile = self.context.pathProvider.configFolder().stringByAppendingPathComponent("app.cfg")

        if !self.fileSystem.fileExists(configFile) {
            context.settings.profile = "Default"
            context.settings.checkForApplicationUpdates = true
            context.settings.downloadPreReleaseVersions = false
            return
        }

        var data:String?

        do {
            data = try self.fileSystem.stringWithContentsOfFile(configFile, encoding: NSUTF8StringEncoding)
        } catch {
            return
        }

        if data == nil {
            return
        }

        do {
            let dict = try JSONSerializer.toDictionary(data!)

            context.settings.defaultProfile = dict.stringValue("defaultProfile", defaultVal: "Default")
            context.settings.checkForApplicationUpdates = dict.boolValue("checkForApplicationUpdates", defaultVal: true)
            context.settings.downloadPreReleaseVersions = dict.boolValue("downloadPreReleaseVersions", defaultVal: false)
        }
        catch {
        }
    }

    func save() {
        let configFile = self.context.pathProvider.configFolder().stringByAppendingPathComponent("app.cfg")

        let settings = BasicSettings(
            defaultProfile: self.context.settings.defaultProfile,
            checkForApplicationUpdates: self.context.settings.checkForApplicationUpdates ? "yes" : "no",
            downloadPreReleaseVersions: self.context.settings.downloadPreReleaseVersions ? "yes" : "no")

        let json = JSONSerializer.toJson(settings, prettify: true)

        self.fileSystem.write(json, toFile: configFile)
    }

    struct BasicSettings {
        var defaultProfile:String
        var checkForApplicationUpdates:String
        var downloadPreReleaseVersions:String
    }
}
