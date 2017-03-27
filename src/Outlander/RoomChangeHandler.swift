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
    func handle(_ nodes:[Node], text:String, context:GameContext)
}

@objc
class RoomChangeHandler : NSObject, NodeHandler {
    
    var relay:CommandRelay
    
    fileprivate var showAfterPrompt = false
    
    class func newInstance(_ relay:CommandRelay) -> RoomChangeHandler {
        return RoomChangeHandler(relay)
    }
    
    init(_ relay:CommandRelay) {
        self.relay = relay
    }
    
    func handle(_ nodes:[Node], text:String, context:GameContext) {
        
        if let zone = context.mapZone {
            
            for node in nodes {
                
                if node.name == "compass" {
                    
                    self.showAfterPrompt = true
                }
                
                if node.name == "prompt" && self.showAfterPrompt {
                    
                    self.showAfterPrompt = false
                    
                    var title = context.globalVars.cacheObject(forKey: "roomtitle") as? String ?? ""
                    let desc = context.globalVars.cacheObject(forKey: "roomdesc") as? String ?? ""
                    
                    title = title.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                    
                    let roomId = context.globalVars.cacheObject(forKey: "roomid") as? String
                    
                    self.findRoom(context, zone: zone, previousRoomId: roomId, name: title, description: desc)
                }
            }
        }
    }
    
    func findRoom(_ context:GameContext, zone:MapZone, previousRoomId:String?, name:String, description:String) {

        let start = Date()

        if let room = zone.findRoomFuzyFrom(previousRoomId, name: name, description: description) {
            
            let diff = Date().timeIntervalSince(start)
            self.send(context, room: room, diff: diff)
        }
        else {
            if let room = context.findRoomInZones(name, description: description) {

                let diff = Date().timeIntervalSince(start)
                self.send(context, room: room, diff: diff)
            }
        }
    }
    
    func send(_ context:GameContext, room:MapNode, diff:Double) {
        
        context.globalVars.setCacheObject(room.id, forKey: "roomid")
        
        var tag = TextTag()
        
        if context.globalVars.cacheObject(forKey: "debugautomapper") as? String == "1" {
        
            tag.text = "[AutoMapper] Debug: Found room #\(room.id) in \(diff) seconds\n"
//            tag.color = "#00ffff"
            tag.preset = "automapper"
            self.relay.sendEcho(tag)
        }
        
        let exits = room.nonCardinalExists().map { $0.move }.joined(separator: ", ")
        
        if exits.characters.count > 0 {
        
            tag = TextTag()
            tag.text = "Mapped exits: \(exits)\n"
//            tag.color = "#00ffff"
            tag.preset = "automapper"
            self.relay.sendEcho(tag)
        }
    }
}
