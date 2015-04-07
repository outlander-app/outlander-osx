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
                var name = context.globalVars.cacheObjectForKey("roomtitle") as String
                name = name.substringWithRange(Range<String.Index>(start: advance(name.startIndex, 1), end: advance(name.endIndex, -1) ))
                
                let description = context.globalVars.cacheObjectForKey("roomdesc") as String
             
                var roomId = context.globalVars.cacheObjectForKey("roomid") as String
                
                if let currentRoom = zone.findRoomFuzyFrom(roomId, name: name, description: description) {
                
                    println("currentRoomId: \(currentRoom.id)")
                    
                    if let toRoom = zone.roomsWithNote(area).last {
                        println("gotoId: \(toRoom.id)")
                        
                        var pathfinder = Pathfinder()
                        let path = pathfinder.findPath(currentRoom.id, target: toRoom.id, zone: zone)
                        
                        let moves = pathfinder.getMoves(path, zone: zone)
                        
                        return moves
                    }
                }
            }
            
            return ["no path found"]
            
        } ~> { (moves) -> () in
            
            let walk = ", ".join(moves)
            
            let diff = NSDate().timeIntervalSinceDate(self.startDate)
            self.sendMessage("Diff: \(diff)")
            
            self.sendMessage("Map path: \(walk)")
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