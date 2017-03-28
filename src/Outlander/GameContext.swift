//
//  GameContext.swift
//  Outlander
//
//  Created by Joseph McBride on 4/7/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
open class GameContext : NSObject {
    
    class func newInstance() -> GameContext {
        return GameContext()
    }
    
    open var settings:AppSettings
    open var pathProvider:AppPathProvider
    open var layout:Layout?
    open var vitalsSettings:VitalsSettings
    open var classSettings:ClassSettings
    
    open var mapZone:MapZone? {
        didSet {
            
            var zoneId = ""
            
            if self.mapZone != nil {
                zoneId = self.mapZone!.id
            }
            
            let lastId = self.globalVars.cacheObject(forKey: "zoneid") as? String ?? ""
            
            if zoneId != lastId {
                self.globalVars.setCacheObject(zoneId, forKey: "zoneid")
            }
        }
    }

    open var maps: [String:MapZone]
    
    open var highlights:OLMutableArray
    open var aliases:OLMutableArray
    open var macros:OLMutableArray
    open var triggers:OLMutableArray
    open var substitutes:OLMutableArray
    open var gags:OLMutableArray
    open var presets:[String:ColorPreset]
    open var globalVars:TSMutableDictionary
    open var events:EventAggregator
    
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
        self.globalVars = TSMutableDictionary(name: "com.outlander.globalvars")

        self.vitalsSettings = VitalsSettings()
        self.classSettings = ClassSettings()
        
        self.events = EventAggregator()
        self.maps = [:]
    }

    open func presetFor(_ setting: String) -> ColorPreset? {

        let settingToCheck = setting.lowercased()

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
open class VitalsSettings : NSObject {
    open var healthColor:String = "#cc0000"
    open var healthTextColor:String = "#f5f5f5"
    open var manaColor:String = "#00004B"
    open var manaTextColor:String = "#f5f5f5"
    open var staminaColor:String = "#004000"
    open var staminaTextColor:String = "#f5f5f5"
    open var concentrationColor:String = "#009999"
    open var concentrationTextColor:String = "#f5f5f5"
    open var spiritColor:String = "#400040"
    open var spiritTextColor:String = "#f5f5f5"
}

@objc
open class ClassSettings : NSObject {

    fileprivate var _values:[String:Bool] = [:]

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

    func set(_ key:String, value:Bool) {
        _values[key.lowercased()] = value
    }

    func parse(_ values:String) {

        if values.hasPrefix("+") || values.hasPrefix("-") {
            let components = values.components(separatedBy: " ")

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

        return items.sorted {
            $0.key.localizedCaseInsensitiveCompare($1.key) == ComparisonResult.orderedAscending
        }
    }

    func disabled() -> [String] {
        var items:[String] = []

        for (key, value) in _values {
            if !value {
                items.append(key)
            }
        }

        return items.sorted {
            $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
        }
    }

    func parseToggleSetting(_ val:String) -> ClassSetting? {

        let list = val.components(separatedBy: " ")

        if list.count < 2 {
            return nil
        }
        
        let key = list[0]
        let symbol:String = list[1]
        let value = symbol.toBool()

        return ClassSetting(key: key.lowercased(), value: value ?? false)
    }

    func parseSetting(_ val:String) -> ClassSetting {

        let key = val.substringFromIndex(1)
        let symbol:String = val[0]
        let value = symbol.toBool()

        return ClassSetting(key: key.lowercased(), value: value ?? false)
    }
}

public struct ClassSetting {
    public var key:String
    public var value:Bool
}
