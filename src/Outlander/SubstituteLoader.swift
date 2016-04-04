//
//  SubstituteLoader.swift
//  Outlander
//
//  Created by Joseph McBride on 4/3/16.
//  Copyright © 2016 Joe McBride. All rights reserved.
//

import Foundation

@objc
class SubstituteLoader : NSObject {
    
    class func newInstance(context:GameContext, fileSystem:FileSystem) -> SubstituteLoader {
        return SubstituteLoader(context: context, fileSystem: fileSystem)
    }
    
    var context:GameContext
    var fileSystem:FileSystem
    
    init(context:GameContext, fileSystem:FileSystem) {
        self.context = context
        self.fileSystem = fileSystem
    }
    
    func load() {
        let configFile = self.context.pathProvider.profileFolder().stringByAppendingPathComponent("substitutes.cfg")
        
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
        
        let pattern = "^#subs \\{(.*?)\\} \\{(.*?)\\}(?:\\s\\{(.*?)\\})?$"
        
        let target = SwiftRegex(target: data!, pattern: pattern, options: [NSRegularExpressionOptions.AnchorsMatchLines, NSRegularExpressionOptions.CaseInsensitive])
        
        let groups = target.allGroups()
        
        for group in groups {
            if group.count == 4 {
                let sub = group[1]
                let action = group[2]
                var className = ""
                
                if group[3] != regexNoGroup {
                    className = group[3]
                }
                
                let item = Substitute(sub, action, className)
                
                self.context.substitutes.addObject(item)
            }
        }
    }
    
    func save() {
        let configFile = self.context.pathProvider.profileFolder().stringByAppendingPathComponent("substitutes.cfg")
        
        var subs = ""
        
        self.context.substitutes.enumerateObjectsUsingBlock({ object, index, stop in
            let sub = object as! Substitute
            let pattern = sub.pattern != nil ? sub.pattern! : ""
            let action = sub.action != nil ? sub.action! : ""
            let className = sub.actionClass != nil ? sub.actionClass! : ""
            
            subs += "#subs {\(pattern)} {\(action)}"
            
            if className.characters.count > 0 {
                subs += " {\(className)}"
            }
            subs += "\n"
        })
        
        self.fileSystem.write(subs, toFile: configFile)
    }
}