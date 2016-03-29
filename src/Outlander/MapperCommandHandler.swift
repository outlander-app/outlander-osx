//
//  MapperCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class MapperCommandHandler : NSObject, CommandHandler {
    
    class func newInstance() -> MapperCommandHandler {
        return MapperCommandHandler()
    }
    
    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#mapper")
    }
    
    func handle(command: String, withContext: GameContext) {
        print("#mapper: \(command)")
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
                var name = context.globalVars.cacheObjectForKey("roomtitle") as? String ?? ""
                name = name.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "[]"))
                
                let description = context.globalVars.cacheObjectForKey("roomdesc") as? String ?? ""
             
                let roomId = context.globalVars.cacheObjectForKey("roomid") as? String ?? ""
                
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
            
            let diff = NSDate().timeIntervalSinceDate(self.startDate)
            
            if context.globalVars.cacheObjectForKey("debugautomapper") as? String == "1" {
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
        tag.color = "#00ffff"
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
