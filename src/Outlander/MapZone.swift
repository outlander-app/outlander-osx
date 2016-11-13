//
//  MapZone.swift
//  TestMapper
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

@objc
public final class MapZone : NSObject {
    var id:String
    var name:String
    var rooms:[MapNode]
    var labels:[MapLabel]
    var roomIdLookup:[String:MapNode]
    
    init(_ id:String, _ name:String) {
        self.id = id
        self.name = name
        rooms = []
        labels = []
        roomIdLookup = [:]
    }
    
    func addRoom(room:MapNode) {
        rooms.append(room)
        roomIdLookup[room.id] = room
    }
    
    func mapSize(z:Int, padding:Double) -> NSRect {
        
        var maxX:Double = 0
        var minX:Double = 0
        var maxY:Double = 0
        var minY:Double = 0
        
        for room in rooms {
            
            if Double(room.position.x) > maxX {
                maxX = Double(room.position.x)
            }
            
            if Double(room.position.x) < minX {
                minX = Double(room.position.x)
            }
            
            if Double(room.position.y) > maxY {
                maxY = Double(room.position.y)
            }
            
            if Double(room.position.y) < minY {
                minY = Double(room.position.y)
            }
        }
        
        let width:Double = abs(maxX) + abs(minX) + padding
        let height:Double = abs(maxY) + abs(minY) + padding
        
        print("maxX: \(maxX) minX: \(minX) maxY: \(maxY) minY: \(minY) || (\(width),\(height))")
       
        // set origin x,y to the point on screen where were the most points can fit on screen
        // between maxX and maxY
        return NSRect(x: width - maxX - (padding / 2.0), y: height - maxY - (padding / 2.0), width: width*1.0, height: height*1.0)
    }
    
    func roomWithId(id:String) -> MapNode? {
        
        if id.characters.count == 0 {
            return nil
        }
        
        return roomIdLookup[id]
    }
    
    func findRoomFrom(id:String, name:String, description:String) -> MapNode? {
        
        let last = roomIdLookup[id]
        
        let trimmed = description
       
//        if description.characters.count > 50 {
//            trimmed = description.substringToIndex(description.startIndex.advancedBy(50))
//        }

        let filtered = last?.arcs.filter { $0.destination.characters.count > 0 }
 
        for arc in filtered! {
            
            if let room = roomIdLookup[arc.destination] {
                
                if room.name == name && room.hasMatchingDescription(trimmed) {
                    return room
                }
            }
        }
       
        return nil
    }
    
    
    func findRoomFuzyFrom(currentRoomId:String?, name:String, description:String) -> MapNode? {
        
        let trimmed = description
       
//        if description.characters.count > 50 {
//            trimmed = description.substringToIndex(description.startIndex.advancedBy(50))
//        }

        let currentRoom = roomWithId(currentRoomId ?? "")
        
        if currentRoom == nil || currentRoom!.name != name || !currentRoom!.hasMatchingDescription(trimmed) {
            return self.findRoom(name, description: description)
        }
        
        return currentRoom
    }
    
    func findRoom(name:String, description:String) -> MapNode? {
        
        let trimmed = description
       
//        if description.characters.count > 50 {
//            trimmed = description.substringToIndex(description.startIndex.advancedBy(50))
//        }

        for room in rooms {
            if room.name == name && room.hasMatchingDescription(trimmed) {
               return room
            }
        }
        
        return nil
    }
    
    func roomsWithNote(note:String) -> [MapNode] {
        
        return self.rooms.filter {
            
            if let notes = $0.notes {
                let split = notes.lowercaseString.componentsSeparatedByString("|")
                let filter = split
                    .filter { $0.hasPrefix(note.lowercaseString) }
                
                return filter.count > 0
            }
            
            return false
        }
    }
    
    func moveCostForNode(node: MapNode, toNode: MapNode) -> Int {
        let index = node.position
        let toIndex = toNode.position
        
        return ((abs(index.x - toIndex.x) > 0 && abs(index.y - toIndex.y) > 0) ? 10 : 14)
    }
    
    func hValueForNode(node: MapNode, endNode: MapNode) -> Int {
        let coord1 = node.position
        let coord2 = endNode.position
        
        return (abs(coord1.x - coord2.x) + abs(coord1.y - coord2.y)) * 40
    }
}
