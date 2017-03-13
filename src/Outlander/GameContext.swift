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
    
    public var mapZone:MapZone? {
        didSet {
            
            var zoneId = ""
            
            if self.mapZone != nil {
                zoneId = self.mapZone!.id
            }
            
            let lastId = self.globalVars.cacheObjectForKey("zoneid") as? String ?? ""
            
            if zoneId != lastId {
                self.globalVars.setCacheObject(zoneId, forKey: "zoneid")
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
    public var globalVars:TSMutableDictionary
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
        self.globalVars = TSMutableDictionary(name: "com.outlander.globalvars")

        self.vitalsSettings = VitalsSettings()
        
        self.events = EventAggregator()
        self.maps = [:]
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
    public var manaColor:String = "#00004B"
    public var staminaColor:String = "#004000"
    public var concentrationColor:String = "#009999"
    public var spiritColor:String = "#400040"
}
