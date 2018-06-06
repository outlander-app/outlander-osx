//
//  MapperCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

extension GameContext {

    func resetMap() {
        if let zone = self.mapZone {
            var name = self.globalVars["roomtitle"] ?? ""
            name = name.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "[]"))

            let description = self.globalVars["roomdesc"] ?? ""

            let roomId = self.globalVars["roomid"] ?? ""

            if let currentRoom = zone.findRoomFuzyFrom(roomId, name: name, description: description) {
                print("reset: found room \(currentRoom.id)")
                self.globalVars["roomid"] = currentRoom.id
            } else {
                findRoomInZones(name, description: description)
            }
        }
    }

    func findRoomInZones(name: String, description: String) -> MapNode? {

        for (_, zone) in self.maps {
            let (found, room) = findRoomInZone(zone, name: name, description: description)
            guard found else { continue }

            print("found room \(room!.id) in zone \(zone.id) - \(zone.name)")

            self.mapZone = zone

//            context.globalVars.setCacheObject(zoneId, forKey: "zoneid")
//            context.globalVars.setCacheObject(roomId!, forKey: "roomid")
            return room
        }

        print("cound not find room")
        return nil
    }

    private func findRoomInZone(zone: MapZone, name:String, description:String) -> (Bool, MapNode?) {

        if let currentRoom = zone.findRoomFuzyFrom(nil, name: name, description: description) {
            return (true, currentRoom)
        }
        
        return (false, nil)
    }
}

@objc
class MapperCommandHandler : NSObject, CommandHandler {
    
    class func newInstance() -> MapperCommandHandler {
        return MapperCommandHandler()
    }
    
    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#mapper")
    }
    
    func handle(command: String, withContext: GameContext) {
        let text = command
            .substringFromIndex(command.startIndex.advancedBy(7))
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        if text == "reset" {
            withContext.resetMap()
        }
        else if text == "reload" {
            withContext.events.publish("OL:map:reload", data: [:])
        }
    }
}

@objc
class MapperGotoCommandHandler : NSObject, CommandHandler {
    
    private var startDate = NSDate()
    private var relay:CommandRelay
    
    class func newInstance(relay:CommandRelay) -> MapperGotoCommandHandler {
        return MapperGotoCommandHandler(relay)
    }
    
    init(_ relay:CommandRelay) {
        self.relay = relay
    }
    
    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#goto")
    }
    
    func handle(command: String, withContext: GameContext) {
        
        let area = command
            .substringFromIndex(command.startIndex.advancedBy(5))
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        self.gotoArea(area, context: withContext)
    }

    func gotoArea(area:String, context:GameContext) {
        
        { () -> [String] in
            
            self.startDate = NSDate()
            
            if let zone = context.mapZone {
                var name = context.globalVars["roomtitle"] ?? ""
                name = name.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "[]"))
                
                let description = context.globalVars["roomdesc"] ?? ""
             
                let roomId = context.globalVars["roomid"] ?? ""
                
                if let currentRoom = zone.findRoomFuzyFrom(roomId, name: name, description: description) {
                
                    print("currentRoomId: \(currentRoom.id)")
                    
                    var toRoom:MapNode?
                    
                    let matches = zone.roomsWithNote(area)
                    
                    for match in matches {
                        toRoom = match
                        self.sendMessage("[\(match.name)] (\(match.id)) - \(match.notes!)")
                    }
                    
                    if toRoom == nil {
                        toRoom = zone.roomWithId(area)
                    }
                    
                    if toRoom != nil {
                        
                        if toRoom!.id == currentRoom.id {
                            
                            self.sendMessage("You are already here!")
                            
                            return []
                        }
                        else {
                        
                            if matches.count == 0 {
                                self.sendMessage("[\(toRoom!.name)] (\(toRoom!.id))")
                            }
                            
                            let pathfinder = Pathfinder()
                            let path = pathfinder.findPath(currentRoom.id, target: toRoom!.id, zone: zone)
                            
                            let moves = pathfinder.getMoves(path, zone: zone)
                                
                            
                            return moves
                        }
                    }
                }
            }
            
            if context.mapZone == nil {
                self.sendMessage("no map data loaded")
                return []
            }
            
            self.sendMessage("no path found for \"\(area)\"")
            
            return []
            
        } ~> { (moves) -> () in
            
            let walk = moves.joinWithSeparator(", ")
            
            if context.globalVars["debugautomapper"] == "1" {
                let diff = NSDate().timeIntervalSinceDate(self.startDate)
                self.sendMessage("Debug: path found in \(diff) seconds")
            }
            
            if walk.characters.count > 0 {
            
                self.sendMessage("Map path: \(walk)")
                self.autoWalk(moves)
            }
        }
    }
    
    func sendMessage(message:String) {
        let tag = TextTag()
        tag.text = "[AutoMapper] \(message)\n"
//        tag.color = "#00ffff"
        tag.preset = "automapper"
        relay.sendEcho(tag)
    }
    
    func autoWalk(moves:[String]) {
        
        var walk = ""
        
        for move in moves {
            if move.rangeOfString(" ") != nil {
                walk += " \"\(move)\""
            } else {
                walk += " \(move)"
            }
        }
        
        let context = CommandContext()
        context.command = ".automapper " + walk
        relay.sendCommand(context)
    }
}
