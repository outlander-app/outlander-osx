//
//  GagLoader.swift
//  Outlander
//
//  Created by Joseph McBride on 6/25/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class GagsLoader : NSObject {
    
    class func newInstance(context:GameContext, fileSystem:FileSystem) -> GagsLoader {
        return GagsLoader(context: context, fileSystem: fileSystem)
    }
    
    var context:GameContext
    var fileSystem:FileSystem

    init(context:GameContext, fileSystem:FileSystem) {
        self.context = context
        self.fileSystem = fileSystem
    }
    
    func load() {
        let configFile = self.context.pathProvider.profileFolder().stringByAppendingPathComponent("gags.cfg")
        
        var data:String?
        
        do {
            data = try self.fileSystem.stringWithContentsOfFile(configFile, encoding: NSUTF8StringEncoding)
        } catch {
            return
        }
        
        if data == nil {
            return
        }
        
        self.context.substitutes.removeAll()
        
        let pattern = "^#gag \\{(.*?)\\}(?:\\s\\{(.*?)\\})?$"
        
        let target = SwiftRegex(target: data!, pattern: pattern, options: [NSRegularExpressionOptions.AnchorsMatchLines, NSRegularExpressionOptions.CaseInsensitive])
        
        let groups = target.allGroups()
        
        for group in groups {
            if group.count == 3 {
                let sub = group[1]
                var className = ""
                
                if group[2] != regexNoGroup {
                    className = group[2]
                }
                
                let item = Gag(sub, className)
                
                self.context.gags.addObject(item)
            }
        }
    }
    
    func save() {
        let configFile = self.context.pathProvider.profileFolder().stringByAppendingPathComponent("gags.cfg")
        
        var gags = ""
        
        self.context.gags.enumerateObjectsUsingBlock({ object, index, stop in
            let gag = object as! Gag
            let pattern = gag.pattern != nil ? gag.pattern! : ""
            let className = gag.patternClass != nil ? gag.patternClass! : ""
            
            gags += "#gag {\(pattern)}"
            
            if className.characters.count > 0 {
                gags += " {\(className)}"
            }
            gags += "\n"
        })
        
        self.fileSystem.write(gags, toFile: configFile)
    }
}
