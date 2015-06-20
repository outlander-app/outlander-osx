//
//  TriggerHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 6/7/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class TriggerHandler : ISubscriber {
    
    class func newInstance(context:GameContext) -> TriggerHandler {
        return TriggerHandler(context: context)
    }
    
    var context:GameContext
    var subId:String?
    
    init(context:GameContext) {
        self.context = context
        self.subId = context.events.subscribe(self, token: "ol:game-parse")
    }
    
    func unsubscribe() {
        if let subId = self.subId {
            self.context.events.unSubscribe(subId)
        }
    }
    
    func handle(token:String, data:Dictionary<String, AnyObject>) {
        if let dict = data as? [String:String] {
            var text = dict["text"] ?? ""
            
            if count(text) > 0 {
                self.checkTriggers(text, context: self.context)
            }
        }
    }
    
    func handle(nodes:[Node], text:String, context:GameContext) {
        self.checkTriggers(text, context: context)
    }
    
    func checkTriggers(text:String, context:GameContext) {
        var triggers = context.triggers;
        
        triggers.enumerateObjectsUsingBlock({ object, index, stop in
            let trigger = object as! Trigger
            
            if let triggerText = trigger.trigger {
            
                let groups = text[triggerText].groups()
                
                if (groups.count > 0) {
                    println("matches")
                }
            }
        });
    }
}