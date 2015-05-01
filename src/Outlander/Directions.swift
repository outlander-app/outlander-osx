//
//  Directions.swift
//  Outlander
//
//  Created by Joseph McBride on 4/30/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

public class DirectionsView : NSView {
    
    var dir = NSImage(named: "Directions")
    var north = NSImage(named: "North")
    var south = NSImage(named: "South")
    var east = NSImage(named: "East")
    var west = NSImage(named: "West")
    var northeast = NSImage(named: "Northeast")
    var northwest = NSImage(named: "Northwest")
    var southeast = NSImage(named: "Southeast")
    var southwest = NSImage(named: "Southwest")
    var out = NSImage(named: "Out")
    var up = NSImage(named: "Up")
    var down = NSImage(named: "Down")
    
    var availableDirections:[String] = []
    
    public func setDirections(dirs:[String]) {
        availableDirections = dirs
        self.needsDisplay = true
    }
    
    public override var flipped:Bool {
        get {
            return true
        }
    }
    
    public override func drawRect(dirtyRect: NSRect) {
        
        dir?.drawInRect(self.bounds)
        
        if find(self.availableDirections, "north") != nil {
            north?.drawInRect(self.bounds)
        }
        
        if find(self.availableDirections, "south") != nil {
            south?.drawInRect(self.bounds)
        }
        
        if find(self.availableDirections, "east") != nil {
            east?.drawInRect(self.bounds)
        }
        
        if find(self.availableDirections, "west") != nil {
            west?.drawInRect(self.bounds)
        }
        
        if find(self.availableDirections, "northeast") != nil {
            northeast?.drawInRect(self.bounds)
        }
        
        if find(self.availableDirections, "northwest") != nil {
            northwest?.drawInRect(self.bounds)
        }
        
        if find(self.availableDirections, "southeast") != nil {
            southeast?.drawInRect(self.bounds)
        }
        
        if find(self.availableDirections, "southwest") != nil {
            southwest?.drawInRect(self.bounds)
        }
        
        if find(self.availableDirections, "up") != nil {
            up?.drawInRect(self.bounds)
        }
        
        if find(self.availableDirections, "down") != nil {
            down?.drawInRect(self.bounds)
        }
        
        if find(self.availableDirections, "out") != nil {
            out?.drawInRect(self.bounds)
        }
    }
}