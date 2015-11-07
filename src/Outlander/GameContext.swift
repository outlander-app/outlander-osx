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
    
    public var mapZone:MapZone? {
        didSet {
            
            var zoneId = ""
            
            if self.mapZone != nil {
                zoneId = self.mapZone!.id
            }
            
            self.globalVars.setCacheObject(zoneId, forKey: "zoneid")
            
        }
    }
    
    public var highlights:OLMutableArray
    public var aliases:OLMutableArray
    public var macros:OLMutableArray
    public var triggers:OLMutableArray
    public var globalVars:TSMutableDictionary
    public var events:EventAggregator
    
    override init() {
        self.settings = AppSettings()
        self.pathProvider = AppPathProvider(settings: settings)
        self.highlights = OLMutableArray()
        self.aliases = OLMutableArray()
        self.macros = OLMutableArray()
        self.triggers = OLMutableArray()
        self.globalVars = TSMutableDictionary(name: "com.outlander.globalvars")
        
        self.events = EventAggregator()
    }
}
