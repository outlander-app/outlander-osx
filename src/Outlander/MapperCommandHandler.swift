//
//  MapperCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class MapperCommandHandler : CommandHandler {
    
    class func newInstance() -> MapperCommandHandler {
        return MapperCommandHandler()
    }
    
    func canHandle(command: String) -> Bool {
        return command.hasPrefix("#mapper")
    }
    
    func handle(command: String, withContext: GameContext) {
        println("#mapper: \(command)")
    }
}

@objc
class MapperGotoCommandHandler : CommandHandler {
    
    var startDate = NSDate()
    
    class func newInstance() -> MapperGotoCommandHandler {
        return MapperGotoCommandHandler()
    }
    
    func canHandle(command: String) -> Bool {
        return command.hasPrefix("#goto")
    }
    
    func handle(command: String, withContext: GameContext) {
        
        let area = command.substringFromIndex(advance(command.startIndex, 5)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        self.gotoArea(area, context: withContext)
    }

    func gotoArea(area:String, context:GameContext) {
        
        { () -> [String] in
            
            self.startDate = NSDate()
            
            if let zone = context.mapZone {
                var name = context.globalVars.cacheObjectForKey("roomtitle") as? String ?? ""
                name = name.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "[]"))
                
                let description = context.globalVars.cacheObjectForKey("roomdesc") as? String ?? ""
             
                var roomId = context.globalVars.cacheObjectForKey("roomid") as? String ?? ""
                
                if let currentRoom = zone.findRoomFuzyFrom(roomId, name: name, description: description) {
                
                    println("currentRoomId: \(currentRoom.id)")
                    
                    var toRoom:MapNode?
                    
                    var matches = zone.roomsWithNote(area)
                    
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
                            
                            var pathfinder = Pathfinder()
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
            
            return ["no path found for \"\(area)\""]
            
        } ~> { (moves) -> () in
            
            let walk = ", ".join(moves)
            
            let diff = NSDate().timeIntervalSinceDate(self.startDate)
            
            if context.globalVars.cacheObjectForKey("debugautomapper") as? String == "1" {
                self.sendMessage("Debug: path found in \(diff) seconds")
            }
            
            if count(walk) > 0 {
            
                self.sendMessage("Map path: \(walk)")
            }
        }
    }
    
    func sendMessage(message:String) {
        let relay = GameCommandRelay()
        
        var tag = TextTag()
        tag.text = "[AutoMapper] \(message)\n"
        tag.color = "#00ffff"
        relay.sendEcho(tag)
    }
}