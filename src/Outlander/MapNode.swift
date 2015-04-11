//
//  MapNode.swift
//  TestMapper
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

final class MapNode {
    var id:String
    var name:String
    var descriptions:[String]
    var notes:String?
    var color:String?
    var arcs:[MapArc]
    var position:MapPosition
    
    private let cardinalDirs = [
        "north",
        "south",
        "east",
        "west",
        "northeast",
        "northwest",
        "southeast",
        "southwest",
        "out",
        "up",
        "down"]
    
    init(id:String, name:String, descriptions:[String], notes:String?, color:String?, position:MapPosition, arcs:[MapArc]) {
        self.id = id
        self.name = name
        self.descriptions = descriptions
        self.notes = notes
        self.color = color
        self.position = position
        self.arcs = arcs
    }
    
    func arcWithId(id:String) -> MapArc? {
        return arcs.filter { $0.destination == id }.first
    }
    
    func nonCardinalExists() -> [MapArc] {
        return arcs.filter { !contains(self.cardinalDirs,$0.exit) }
    }
    
    func hasMatchingDescription(description:String) -> Bool {

        for desc in descriptions {
            
            if desc.hasPrefix(description) {
                return true
            }
            
        }
        
        return false
    }
}