//
//  MapZone.swift
//  TestMapper
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

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
        
        return NSRect(x: width - maxX - (padding / 2.0), y: height - maxY - (padding / 2.0), width: width*1.0, height: height*1.0)
    }
    
    public func roomWithId(id:String) -> MapNode? {
        return roomIdLookup[id]
    }
    
    public func findRoom(name:String, description:String) -> MapNode? {
        return rooms.filter { room in
            if room.name == name {
                
                for desc in room.descriptions {
                    let res = diff([Character](desc), [Character](description))
                        .filter { $0.type == OperationType.Insert || $0.type == OperationType.Delete }
                    if res.count <= 5 {
                        return true
                    }
                }
            }
            return false
        }.first
    }
    
    public func roomsWithNote(note:String) -> [MapNode] {
        return rooms.filter {
            
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