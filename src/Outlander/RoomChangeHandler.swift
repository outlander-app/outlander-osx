//
//  RoomChangeHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/5/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
public protocol NodeHandler {
    func handle(nodes:[Node], context:GameContext)
}

@objc
class RoomChangeHandler : NodeHandler {
    
    var commandRelay = GameCommandRelay()
    
    class func newInstance() -> RoomChangeHandler {
        return RoomChangeHandler()
    }
    
    func handle(nodes:[Node], context:GameContext) {
        
        if let zone = context.mapZone {
            
            for node in nodes {
        
                if node.name == "compass" {
                    
                    var title = context.globalVars.cacheObjectForKey("roomtitle") as String
                    var desc = context.globalVars.cacheObjectForKey("roomdesc") as String
                    
                    title = title.substringWithRange(Range<String.Index>(start: advance(title.startIndex, 1), end: advance(title.endIndex, -1) ))
                    
                    var roomId = context.globalVars.cacheObjectForKey("roomid") as String?
                    
                    self.findRoom(context, zone: zone, previousRoomId: roomId, name: title, description: desc)
                }
            }
        }
    }
    
    func findRoom(context:GameContext, zone:MapZone, previousRoomId:String?, name:String, description:String) {
        
        { () -> Void in
            let start = NSDate()
        
            if let room = zone.findRoomFuzyFrom(previousRoomId, name: name, description: description) {
                let diff = NSDate().timeIntervalSinceDate(start)
                
                self.send(context, room: room, diff: diff)
            }
            
        } ~> { () -> Void in
        }
    }
    
    func send(context:GameContext, room:MapNode, diff:Double) {
        
        var tag = TextTag()
        tag.text = "\(room.id) - \(diff)\n"
        tag.color = "#00ffff"
        self.commandRelay.sendEcho(tag)
        
        var exits = ", ".join(room.nonCardinalExists().map { $0.move })
        
        if countElements(exits) > 0 {
        
            tag = TextTag()
            tag.text = "Mapped exits: \(exits)\n"
            tag.color = "#00ffff"
            self.commandRelay.sendEcho(tag)
            
        }
        
        context.globalVars.setCacheObject(room.id, forKey: "roomid")
    }
}