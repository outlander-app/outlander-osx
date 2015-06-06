//
//  TriggersLoader.swift
//  Outlander
//
//  Created by Joseph McBride on 6/5/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

class TriggersLoader {
    
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
        
        let pattern = "^#trigger \\{(.*)\\} \\{(.*)\\}(\\s\\{(.*)\\})?$"
        let groups = data[pattern].allGroups()
        
        for group in groups {
            if group.count == 5 {
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
    }
    
}