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
        
        if self.availableDirections.indexOf("north") != nil {
            north?.drawInRect(self.bounds)
        }
        
        if self.availableDirections.indexOf("south") != nil {
            south?.drawInRect(self.bounds)
        }
        
        if self.availableDirections.indexOf("east") != nil {
            east?.drawInRect(self.bounds)
        }
        
        if self.availableDirections.indexOf("west") != nil {
            west?.drawInRect(self.bounds)
        }
        
        if self.availableDirections.indexOf("northeast") != nil {
            northeast?.drawInRect(self.bounds)
        }
        
        if self.availableDirections.indexOf("northwest") != nil {
            northwest?.drawInRect(self.bounds)
        }
        
        if self.availableDirections.indexOf("southeast") != nil {
            southeast?.drawInRect(self.bounds)
        }
        
        if self.availableDirections.indexOf("southwest") != nil {
            southwest?.drawInRect(self.bounds)
        }
        
        if self.availableDirections.indexOf("up") != nil {
            up?.drawInRect(self.bounds)
        }
        
        if self.availableDirections.indexOf("down") != nil {
            down?.drawInRect(self.bounds)
        }
        
        if self.availableDirections.indexOf("out") != nil {
            out?.drawInRect(self.bounds)
        }
    }
}