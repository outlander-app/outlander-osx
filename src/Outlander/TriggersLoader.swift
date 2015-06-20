//
//  TriggersLoader.swift
//  Outlander
//
//  Created by Joseph McBride on 6/5/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class TriggersLoader {
    
    class func newInstance(context:GameContext, fileSystem:FileSystem) -> TriggersLoader {
        return TriggersLoader(context: context, fileSystem: fileSystem)
    }
    
    var context:GameContext
    var fileSystem:FileSystem

    init(context:GameContext, fileSystem:FileSystem) {
        self.context = context
        self.fileSystem = fileSystem
    }
    
    func load() {
        let configFile = self.context.pathProvider.profileFolder().stringByAppendingPathComponent("triggers.cfg")
       
        var error:NSError?
        var data = self.fileSystem.stringWithContentsOfFile(configFile, encoding: NSUTF8StringEncoding, error: &error)
        
        if error != nil || data == nil {
            return
        }
        
        let pattern = "^#trigger \\{(.*?)\\} \\{(.*?)\\}(?:\\s\\{(.*?)\\})?$"
        
        var target = SwiftRegex(target: data, pattern: pattern, options: NSRegularExpressionOptions.AnchorsMatchLines|NSRegularExpressionOptions.CaseInsensitive)
        
        let groups = target.allGroups()
        
        for group in groups {
            if group.count == 4 {
                let trigger = group[1]
                let action = group[2]
                var className = ""
                
                if group[3] != "_" {
                    className = group[3]
                }
                
                let item = Trigger(trigger, action, className)
                
                self.context.triggers.addObject(item)
            }
        }
    }
    
    func save() {
        
        let configFile = self.context.pathProvider.profileFolder().stringByAppendingPathComponent("triggers.cfg")
        
        var triggers = ""
        
        self.context.triggers.enumerateObjectsUsingBlock({ object, index, stop in
            var trigger = object as! Trigger
            var triggerText = trigger.trigger != nil ? trigger.trigger! : ""
            var action = trigger.action != nil ? trigger.action! : ""
            var className = trigger.actionClass != nil ? trigger.actionClass! : ""
            
            triggers += "#trigger {\(triggerText)} {\(action)}"
            
            if count(trigger.className) > 0 {
                triggers += " {\(className)}"
            }
            triggers += "\n"
        })
        
        self.fileSystem.write(triggers, toFile: configFile)
    }
    
}