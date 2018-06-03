//
//  GameContext.swift
//  Outlander
//
//  Created by Joseph McBride on 4/7/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
public class GameContext : NSObject {
    
    class func newInstance() -> GameContext {
        return GameContext()
    }

    public var settings:AppSettings
    public var pathProvider:AppPathProvider
    public var layout:Layout?
    public var vitalsSettings:VitalsSettings
    public var classSettings:ClassSettings
    
    public var mapZone:MapZone? {
        didSet {
            
            var zoneId = ""
            
            if self.mapZone != nil {
                zoneId = self.mapZone!.id
            }
            
            let lastId = self.globalVars["zoneid"] ?? ""
            
            if zoneId != lastId {
                self.globalVars["zoneid"] = zoneId
            }
        }
    }

    public var maps: [String:MapZone]
    
    public var highlights:OLMutableArray
    public var aliases:OLMutableArray
    public var macros:OLMutableArray
    public var triggers:OLMutableArray
    public var substitutes:OLMutableArray
    public var gags:OLMutableArray
    public var presets:[String:ColorPreset]
    public var globalVars:GlobalVariables
    public var events:EventAggregator
    
    override init() {
        self.settings = AppSettings()
        self.pathProvider = AppPathProvider(settings: settings)
        self.highlights = OLMutableArray()
        self.aliases = OLMutableArray()
        self.macros = OLMutableArray()
        self.triggers = OLMutableArray()
        self.substitutes = OLMutableArray()
        self.gags = OLMutableArray()
        self.presets = [:]
        self.globalVars = GlobalVariables("com.outlander.globalVars", Clock(), self.settings)

        self.vitalsSettings = VitalsSettings()
        self.classSettings = ClassSettings()
        
        self.events = EventAggregator()
        self.maps = [:]

        super.init()

        self.globalVars.listen { (key, value) in
            self.events.publish("variable:changed", data: [key : value ?? ""])
        }
    }

    public func presetFor(setting: String) -> ColorPreset? {

        let settingToCheck = setting.lowercaseString

        if settingToCheck.characters.count == 0 {
            return ColorPreset("", "#cccccc")
        }
        
        if let preset = self.presets[settingToCheck] {
            return preset
        }

        return ColorPreset("", "#cccccc")
    }
}

@objc
public class VitalsSettings : NSObject {
    public var healthColor:String = "#cc0000"
    public var healthTextColor:String = "#f5f5f5"
    public var manaColor:String = "#00004B"
    public var manaTextColor:String = "#f5f5f5"
    public var staminaColor:String = "#004000"
    public var staminaTextColor:String = "#f5f5f5"
    public var concentrationColor:String = "#009999"
    public var concentrationTextColor:String = "#f5f5f5"
    public var spiritColor:String = "#400040"
    public var spiritTextColor:String = "#f5f5f5"
}

@objc
public class ClassSettings : NSObject {

    private var _values:[String:Bool] = [:]

    func clear() {
        _values.removeAll()
    }

    func allOn() {
        for (key, _) in _values {
            _values[key] = true
        }
    }

    func allOff() {
        for (key, _) in _values {
            _values[key] = false
        }
    }

    func set(key:String, value:Bool) {
        _values[key.lowercaseString] = value
    }

    func parse(values:String) {

        if values.hasPrefix("+") || values.hasPrefix("-") {
            let components = values.componentsSeparatedByString(" ")

            for comp in components {
                let s = parseSetting(comp)
                self.set(s.key, value: s.value)
            }

            return
        }

        if let s = parseToggleSetting(values) {

            if s.key == "all" {

                s.value ? allOn() : allOff()
                
            } else {
                self.set(s.key, value: s.value)
            }
        }
    }

    func all() -> [ClassSetting] {
        var items:[ClassSetting] = []

        for (key, value) in _values {
            items.append(ClassSetting(key: key, value: value))
        }

        return items.sort {
            $0.key.localizedCaseInsensitiveCompare($1.key) == NSComparisonResult.OrderedAscending
        }
    }

    func disabled() -> [String] {
        var items:[String] = []

        for (key, value) in _values {
            if !value {
                items.append(key)
            }
        }

        return items
    }

    func parseToggleSetting(val:String) -> ClassSetting? {

        let list = val.componentsSeparatedByString(" ")

        if list.count < 2 {
            return nil
        }
        
        let key = list[0]
        let symbol:String = list[1]
        let value = symbol.toBool()

        return ClassSetting(key: key.lowercaseString, value: value ?? false)
    }

    func parseSetting(val:String) -> ClassSetting {

        let key = val.substringFromIndex(1)
        let symbol:String = val[0]
        let value = symbol.toBool()

        return ClassSetting(key: key.lowercaseString, value: value ?? false)
    }
}

public struct ClassSetting {
    public var key:String
    public var value:Bool
}
