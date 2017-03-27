//
//  ScriptStreamHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/13/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
open class ScriptStreamHandler : NSObject, NodeHandler {
    
    class func newInstance() -> ScriptStreamHandler {
        return ScriptStreamHandler()
    }
    
    open func handle(_ nodes:[Node], text:String, context:GameContext) {
        var dict:[String:AnyObject] = [:]
        dict["nodes"] = nodes as AnyObject?
        dict["text"] = text as AnyObject?
        
        context.events.publish("ol:game-stream", data: dict)
    }
}
