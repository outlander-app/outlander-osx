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
            var name = self.globalVars.cacheObject(forKey: "roomtitle") as? String ?? ""
            name = name.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))

            let description = self.globalVars.cacheObject(forKey: "roomdesc") as? String ?? ""

            let roomId = self.globalVars.cacheObject(forKey: "roomid") as? String ?? ""

            if let currentRoom = zone.findRoomFuzyFrom(roomId, name: name, description: description) {
                print("reset: found room \(currentRoom.id)")
                self.globalVars.setCacheObject(currentRoom.id, forKey: "roomid")
            } else {
                findRoomInZones(name, description: description)
            }
        }
    }

    func findRoomInZones(_ name: String, description: String) -> MapNode? {

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

    fileprivate func findRoomInZone(_ zone: MapZone, name:String, description:String) -> (Bool, MapNode?) {

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
    
    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#mapper")
    }
    
    func handle(_ command: String, with withContext: GameContext) {
        let text = command
            .substring(from: command.characters.index(command.startIndex, offsetBy: 7))
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if text == "reset" {
            withContext.resetMap()
        }
    }
}

@objc
class MapperGotoCommandHandler : NSObject, CommandHandler {
    
    fileprivate var startDate = Date()
    fileprivate var relay:CommandRelay
    
    class func newInstance(_ relay:CommandRelay) -> MapperGotoCommandHandler {
        return MapperGotoCommandHandler(relay)
    }
    
    init(_ relay:CommandRelay) {
        self.relay = relay
    }
    
    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#goto")
    }
    
    func handle(_ command: String, with withContext: GameContext) {
        
        let area = command
            .substring(from: command.characters.index(command.startIndex, offsetBy: 5))
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        self.gotoArea(area, context: withContext)
    }

    func gotoArea(_ area:String, context:GameContext) {
        
        { () -> [String] in
            
            self.startDate = Date()
            
            if let zone = context.mapZone {
                var name = context.globalVars.cacheObject(forKey: "roomtitle") as? String ?? ""
                name = name.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                
                let description = context.globalVars.cacheObject(forKey: "roomdesc") as? String ?? ""
             
                let roomId = context.globalVars.cacheObject(forKey: "roomid") as? String ?? ""
                
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
            
            let walk = moves.joined(separator: ", ")
            
            if context.globalVars.cacheObject(forKey: "debugautomapper") as? String == "1" {
                let diff = Date().timeIntervalSince(self.startDate)
                self.sendMessage("Debug: path found in \(diff) seconds")
            }
            
            if walk.characters.count > 0 {
            
                self.sendMessage("Map path: \(walk)")
                self.autoWalk(moves)
            }
        }
    }
    
    func sendMessage(_ message:String) {
        let tag = TextTag()
        tag.text = "[AutoMapper] \(message)\n"
//        tag.color = "#00ffff"
        tag.preset = "automapper"
        relay.sendEcho(tag)
    }
    
    func autoWalk(_ moves:[String]) {
        
        var walk = ""
        
        for move in moves {
            if move.range(of: " ") != nil {
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
