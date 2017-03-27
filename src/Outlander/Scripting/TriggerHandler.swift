//
//  TriggerHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 6/7/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class TriggerHandler : NSObject, ISubscriber {
    
    class func newInstance(_ context:GameContext, relay:CommandRelay) -> TriggerHandler {
        return TriggerHandler(context: context, relay: relay)
    }
    
    let context:GameContext
    let relay:CommandRelay
    var subId:String?
    
    init(context:GameContext, relay:CommandRelay) {
        self.context = context
        self.relay = relay
        super.init()
        self.subId = context.events.subscribe(self, token: "ol:game-parse")
    }
    
    func unsubscribe() {
        if let subId = self.subId {
            self.context.events.unSubscribe(subId)
        }
    }
    
    func handle(_ token:String, data:Dictionary<String, AnyObject>) {
        if let dict = data as? [String:String] {
            let text = dict["text"] ?? ""
            
            if text.characters.count > 0 {
                self.checkTriggers(text, context: self.context)
            }
        }
    }
    
    func handle(_ nodes:[Node], text:String, context:GameContext) {
        self.checkTriggers(text, context: context)
    }
    
    func checkTriggers(_ text:String, context:GameContext) {

        let disabledClasses = context.classSettings.disabled()

        let triggers = context.triggers.filter(NSPredicate { (obj, _) in
            let trig = obj as! Trigger

            if let c = trig.actionClass {
                return !disabledClasses.contains(c.lowercased())
            }

            return true
        })

        for object in triggers! {
            let trigger = object as! Trigger
            
            if let triggerText = trigger.trigger {
            
                for groups in text[triggerText].allGroups() {
                    if groups.count > 0 {
                        let command = self.replaceWithGroups(trigger.action ?? "", groups:groups)
                        let commands = command.splitToCommands()

                        for c in commands {
                            let commandContext = CommandContext()
                            commandContext.command = c
                            self.relay.sendCommand(commandContext)
                        }
                    }
                }
            }
        }
    }

    fileprivate func replaceWithGroups(_ input:String, groups:[String?]) -> String {
        var vars = [String:String]()
        for (index, param) in groups.enumerated() {
            vars["\(index)"] = param
        }
        
        let mutable = input.mutable
        
        self.replace("\\$", target: mutable, dict: vars)
        
        return mutable as String
    }
    
    fileprivate func replace(_ prefix:String, target:NSMutableString, dict:[String:String]) {
        
        for key in dict.keys {
            target["\(prefix)\(key)"] ~= dict[key] ?? ""
        }
    }
}
