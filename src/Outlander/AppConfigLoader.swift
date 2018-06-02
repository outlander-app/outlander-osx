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

    let defaultDateFormat = "yyyy-MM-dd"
    let defaultTimeFormat = "hh:mm:ss a"
    let defaultDateTimeFormat = "yyyy-MM-dd hh:mm:ss a"

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
            context.settings.variableDateFormat = defaultDateFormat
            context.settings.variableTimeFormat = defaultTimeFormat
            context.settings.variableDatetimeFormat = defaultDateTimeFormat
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

            self.context.settings.defaultProfile = dict.stringValue("defaultProfile", defaultVal: "Default")
            self.context.settings.checkForApplicationUpdates = dict.boolValue("checkForApplicationUpdates", defaultVal: true)
            self.context.settings.downloadPreReleaseVersions = dict.boolValue("downloadPreReleaseVersions", defaultVal: false)
            self.context.settings.variableDateFormat = dict.stringValue("variableDateFormat", defaultVal: defaultDateFormat)
            self.context.settings.variableTimeFormat = dict.stringValue("variableTimeFormat", defaultVal: defaultTimeFormat)
            self.context.settings.variableDatetimeFormat = dict.stringValue("variableDatetimeFormat", defaultVal: defaultDateTimeFormat)
        }
        catch {
        }
    }

    func save() {
        let configFile = self.context.pathProvider.configFolder().stringByAppendingPathComponent("app.cfg")

        let settings = BasicSettings(
            defaultProfile: self.context.settings.defaultProfile,
            checkForApplicationUpdates: self.context.settings.checkForApplicationUpdates ? "yes" : "no",
            downloadPreReleaseVersions: self.context.settings.downloadPreReleaseVersions ? "yes" : "no",
            variableDateFormat: self.context.settings.variableDateFormat,
            variableTimeFormat: self.context.settings.variableTimeFormat,
            variableDatetimeFormat: self.context.settings.variableDatetimeFormat)

        let json = JSONSerializer.toJson(settings, prettify: true)

        self.fileSystem.write(json, toFile: configFile)
    }

    struct BasicSettings {
        var defaultProfile:String
        var checkForApplicationUpdates:String
        var downloadPreReleaseVersions:String
        var variableDateFormat:String
        var variableTimeFormat:String
        var variableDatetimeFormat:String
    }
}
