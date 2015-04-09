//
//  MapZone.swift
//  TestMapper
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

@objc
public class MapZone {
    var id:String
    var name:String
    var rooms:[MapNode]
    var roomIdLookup:[String:MapNode]
    
    init(_ id:String, _ name:String) {
        self.id = id
        self.name = name
        rooms = []
        roomIdLookup = [:]
    }
    
    public func addRoom(room:MapNode) {
        rooms.append(room)
        roomIdLookup[room.id] = room
    }
    
    public func mapSize(z:Int, padding:Double) -> NSRect {
        
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
        
        var width:Double = abs(maxX) + abs(minX) + padding
        var height:Double = abs(maxY) + abs(minY) + padding
        
        println("maxX: \(maxX) minX: \(minX) maxY: \(maxY) minY: \(minY) || (\(width),\(height))")
       
        // set origin x,y to the point on screen where were the most points can fit on screen
        // between maxX and maxY
        return NSRect(x: width - maxX - (padding / 2.0), y: height - maxY - (padding / 2.0), width: width*1.0, height: height*1.0)
    }
    
    public func roomWithId(id:String) -> MapNode? {
        
        if count(id) == 0 {
            return nil
        }
        
        return roomIdLookup[id]
    }
    
    public func findRoomFrom(id:String, name:String, description:String) -> MapNode? {
        
        var last = roomIdLookup[id]
        
        var trimmed = description
       
        if count(description) > 10 {
            trimmed = description.substringToIndex(advance(description.startIndex, 10))
        }
        
        let filtered = last?.arcs.filter { count($0.destination) > 0 }
 
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
        
        var trimmed = description
       
        if count(description) > 10 {
            trimmed = description.substringToIndex(advance(description.startIndex, 10))
        }
        
        var currentRoom = roomWithId(currentRoomId ?? "")
        
        if currentRoom == nil || currentRoom!.name != name || !currentRoom!.hasMatchingDescription(trimmed) {
            return self.findRoom(name, description: description)
        }
        
        return currentRoom
    }
    
    public func findRoom(name:String, description:String) -> MapNode? {
        
        var trimmed = description
       
        if count(description) > 10 {
            trimmed = description.substringToIndex(advance(description.startIndex, 10))
        }
        
        for room in rooms {
            if room.name == name && room.hasMatchingDescription(trimmed) {
               return room
            }
        }
        
        return nil
    }
    
    public func roomsWithNote(note:String) -> [MapNode] {
        
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
    
    public func moveCostForNode(node: MapNode, toNode: MapNode) -> Int {
        let index = node.position
        let toIndex = toNode.position
        
        return ((abs(index.x - toIndex.x) > 0 && abs(index.y - toIndex.y) > 0) ? 10 : 14)
    }
    
    public func hValueForNode(node: MapNode, endNode: MapNode) -> Int {
        let coord1 = node.position
        let coord2 = endNode.position
        
        return (abs(coord1.x - coord2.x) + abs(coord1.y - coord2.y)) * 40
    }
}