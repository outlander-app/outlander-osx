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
    func handle(nodes:[Node], text:String, context:GameContext)
}

@objc
class RoomChangeHandler : NSObject, NodeHandler {
    
    var relay:CommandRelay
    
    private var showAfterPrompt = false
    private var movedRooms = false
    
    class func newInstance(relay:CommandRelay) -> RoomChangeHandler {
        return RoomChangeHandler(relay)
    }
    
    init(_ relay:CommandRelay) {
        self.relay = relay
    }
    
    func handle(nodes:[Node], text:String, context:GameContext) {
        
        if let zone = context.mapZone {
            
            for node in nodes {

                if node.name == "nav" {
                    self.movedRooms = true
                }
                
                if node.name == "compass" {
                    self.showAfterPrompt = true
                }
                
                if node.name == "prompt" && self.showAfterPrompt {

                    self.showAfterPrompt = false
                    let assignRoom = self.movedRooms
                    self.movedRooms = false
                    
                    let title = context.trimmedRoomTitle()
                    let desc = context.globalVars["roomdesc"] ?? ""
                    
                    let roomId = context.globalVars["roomid"]

                    let start = NSDate()

                    if let room = self.findRoom(context, zone: zone, previousRoomId: roomId, name: title, description: desc) {

                        // check for edge of map, change zone if needed
                        let swapped = self.swapMaps(context, room: room, name: title, description: desc)

                        let diff = NSDate().timeIntervalSinceDate(start)
                        self.send(context, room: swapped, diff: diff, assignRoom: assignRoom)
                    }
                }
            }
        }
    }
    
    func findRoom(context:GameContext, zone:MapZone, previousRoomId:String?, name:String, description:String) -> MapNode? {

        let exits = context.availableExits()

        if let room = zone.findRoomFuzyFrom(previousRoomId, name: name, description: description, exits: exits) {
            return room
        }

        return context.findRoomInZones(name, description: description, exits: exits)
    }

    func send(context:GameContext, room:MapNode, diff:Double, assignRoom:Bool) {

        var tag = TextTag()
        
        if context.globalVars["debugautomapper"] == "1" {
        
            tag.text = "[AutoMapper] Debug: Found room #\(room.id) in \(diff) seconds\n"
            tag.preset = "automapper"
            self.relay.sendEcho(tag)
        }
        
        let exits = room.nonCardinalExists().map { $0.move }.joinWithSeparator(", ")
        
        if exits.characters.count > 0 {
        
            tag = TextTag()
            tag.text = "Mapped exits: \(exits)\n"
            tag.preset = "automapper"
            self.relay.sendEcho(tag)
        }

        if assignRoom {
            context.globalVars["roomid"] = room.id
        }
    }

    func swapMaps(context:GameContext, room:MapNode, name:String, description:String) -> MapNode {
        if room.notes != nil && room.notes!.rangeOfString(".xml") != nil {

            let groups = room.notes!["(.+\\.xml)"].groups()
            
            if groups.count > 1 {
                let mapfile = groups[1]
                if let zone = context.zoneFromFile(mapfile) {

                    context.mapZone = zone

                    if let found = self.findRoom(context, zone: zone, previousRoomId: nil, name: name, description: description) {
                        return found
                    }
                }
            }
        }

        return room
    }
}
