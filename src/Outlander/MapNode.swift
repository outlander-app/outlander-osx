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

    var transferMap:String? {
        get {
            if self.isTransfer() {
                let groups = self.notes?["(.+\\.xml)"].groups()
                if groups?.count > 1 {
                    return groups?[1]
                }
            }

            return nil
        }
    }

    func isTransfer() -> Bool {
        return self.notes?.containsString(".xml") == true
    }
    
    func arcWithId(id:String) -> MapArc? {
        return arcs.filter { $0.destination == id }.first
    }
    
    func nonCardinalExists() -> [MapArc] {
        return arcs.filter { !self.cardinalDirs.contains($0.exit) }
    }

    func cardinalExits() -> [String] {
        return arcs.filter { self.cardinalDirs.contains($0.exit) }.map { $0.exit }.sort()
    }

    func matchesExits(exits: [String]) -> Bool {
        return self.cardinalExits().elementsEqual(exits, isEquivalent: {
            $0 == $1
        })
    }

    func matches(name:String, description:String, exits:[String], ignoreTransfers:Bool) -> Bool {

        if (ignoreTransfers && self.isTransfer()) {
            return false
        }

        if exits.count > 0 {
            return self.matchesExits(exits)
                && self.name == name
                && self.hasMatchingDescription(description)
        }

        return self.name == name && self.hasMatchingDescription(description)
    }

    func hasMatchingDescription(description:String) -> Bool {

        let mod = description.replace("\"", withString: "").replace(";", withString: "")

        for desc in descriptions {
            
            if desc.hasPrefix(mod) {
                return true
            }
            
        }
        
        return false
    }
}
