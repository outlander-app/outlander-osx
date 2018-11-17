//
//  MapperCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

extension String {

    func caseInsensitiveComponents(separatedBy separator: String) -> [String] {
        if let range = self.rangeOfString(separator, options: NSStringCompareOptions.CaseInsensitiveSearch) {
            let start = self.substringToIndex(range.startIndex).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let end = self.substringFromIndex(range.endIndex).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            return [start, end]
        }

        return [self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())]
    }
}

extension GameContext {

    func trimmedRoomTitle() -> String {
        let name = self.globalVars["roomtitle"] ?? ""
        return name.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "[]"))
    }

    func availableExits() -> [String] {
        let dirs = [
            "down",
            "east",
            "north",
            "northeast",
            "northwest",
            "out",
            "south",
            "southeast",
            "southwest",
            "up",
            "west"
        ]

        var avail:[String] = []

        for dir in dirs {
            let value = self.globalVars[dir] ?? ""
            if value == "1" {
                avail.append(dir)
            }
        }

        return avail
    }

    func zoneFromFile(file:String) -> MapZone? {

        for (_, zone) in self.maps {
            if zone.file == file {
                return zone
            }
        }

        return nil
    }

    func resetMap() {
        if let zone = self.mapZone {
            let name = self.trimmedRoomTitle()

            let description = self.globalVars["roomdesc"] ?? ""
            let exits = self.availableExits()

            if let currentRoom = zone.findRoomFuzyFrom("", name: name, description: description, exits: exits, ignoreTransfers: true) {
                print("reset: found room \(currentRoom.id)")
                self.globalVars["roomid"] = currentRoom.id
            } else {
                findRoomInZones(name, description: description, exits: exits)
            }
        }
    }

    func findRoomInZones(name: String, description: String, exits:[String]) -> MapNode? {

        for (_, zone) in self.maps {
            let (found, room) = findRoomInZone(zone, name: name, description: description, exits: exits)
            guard found else { continue }

            print("found room \(room!.id) in zone \(zone.id) - \(zone.name)")

            self.mapZone = zone

            return room
        }

        print("could not find room")
        return nil
    }

    private func findRoomInZone(zone: MapZone, name:String, description:String, exits:[String]) -> (Bool, MapNode?) {

        if let currentRoom = zone.findRoomFuzyFrom(nil, name: name, description: description, exits: exits, ignoreTransfers: true) {
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
            .lowercaseString

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
            .caseInsensitiveComponents(separatedBy: "from")

        if area.count > 1 {
            self.gotoArea(
                area[0],
                from: area[1],
                context: withContext)
        } else if area.count > 0 {
            self.gotoArea(
                area[0],
                context: withContext)
        }
    }

    func gotoArea(area:String, from:String, context:GameContext) {

        { () -> [String] in
            
            self.startDate = NSDate()

            let (fromRoom, _) = self.roomFor(context.mapZone, area: from)
            let (toRoom, matches) = self.roomFor(context.mapZone, area: area)

            return self.goto(context, to: toRoom, from: fromRoom, matches: matches, area: area)

        } ~> { (moves) -> () in
           self.processMoves(context, moves: moves)
        }
    }

    func goto(context:GameContext, to:MapNode?, from:MapNode?, matches:[MapNode], area:String) -> [String] {

        guard let zone = context.mapZone else {
            self.sendMessage("no map data loaded")
            self.sendCommand("#parse AUTOMAPPER NO MAP DATA")
            return []
        }

        for match in matches {
            let notes = match.notes ?? ""
            let display = notes.characters.count > 0 ? " - \(notes)" : ""
            self.sendMessage("[\(match.name)] (\(match.id))\(display)")
        }

        guard to != nil && from != nil else {
            self.sendMessage("no path found for \"\(area)\"")
            self.sendCommand("#parse AUTOMAPPER NO PATH FOUND")
            return []
        }

        if to!.id == from!.id {
            
            self.sendMessage("You are already here!")
            self.sendCommand("#parse AUTOMAPPER ALREADY HERE")
            
            return []
        }
        else {

            if matches.count == 0 {
                self.sendMessage("[\(to!.name)] (\(to!.id))")
            }

            let pathfinder = Pathfinder()
            let path = pathfinder.findPath(from!.id, target: to!.id, zone: zone)
            
            let moves = pathfinder.getMoves(path, zone: zone)

            return moves
        }
    }

    func gotoArea(area:String, context:GameContext) {
        
        { () -> [String] in
            
            self.startDate = NSDate()

            var to:MapNode? = nil
            var from:MapNode? = nil
            var matches:[MapNode] = []

            if let zone = context.mapZone {
                let roomId = context.globalVars["roomid"] ?? ""
                from = zone.roomWithId(roomId)

                let (toRoom, m) = self.roomFor(zone, area: area)
                to = toRoom
                matches = m
            }

            return self.goto(context, to: to, from: from, matches: matches, area: area)

        } ~> { (moves) -> () in
           self.processMoves(context, moves: moves)
        }
    }

    func processMoves(context:GameContext, moves:[String]) {
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

    func roomFor(zone:MapZone?, area:String) -> (MapNode?, [MapNode]) {
        guard zone != nil else {
            return (nil, [])
        }

        var toRoom:MapNode?
        
        let matches = zone!.roomsWithNote(area)
        
        for match in matches {
            toRoom = match
//            self.sendMessage("[\(match.name)] (\(match.id)) - \(match.notes!)")
        }
        
        if toRoom == nil {
            toRoom = zone!.roomWithId(area)
        }

        return (toRoom, matches)
    }

    func sendCommand(command:String) {
        let ctx = CommandContext()
        ctx.command = command
        relay.sendCommand(ctx)
    }
    
    func sendMessage(message:String) {
        let tag = TextTag()
        tag.text = "[AutoMapper] \(message)\n"
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
