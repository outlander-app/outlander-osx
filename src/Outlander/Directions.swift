//
//  Directions.swift
//  Outlander
//
//  Created by Joseph McBride on 4/30/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

open class DirectionsView : NSView {
    
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
    
    open func setDirections(_ dirs:[String]) {
        availableDirections = dirs
        self.needsDisplay = true
    }
    
    open override var isFlipped:Bool {
        get {
            return true
        }
    }
    
    open override func draw(_ dirtyRect: NSRect) {
        
        dir?.draw(in: self.bounds)
        
        if self.availableDirections.index(of: "north") != nil {
            north?.draw(in: self.bounds)
        }
        
        if self.availableDirections.index(of: "south") != nil {
            south?.draw(in: self.bounds)
        }
        
        if self.availableDirections.index(of: "east") != nil {
            east?.draw(in: self.bounds)
        }
        
        if self.availableDirections.index(of: "west") != nil {
            west?.draw(in: self.bounds)
        }
        
        if self.availableDirections.index(of: "northeast") != nil {
            northeast?.draw(in: self.bounds)
        }
        
        if self.availableDirections.index(of: "northwest") != nil {
            northwest?.draw(in: self.bounds)
        }
        
        if self.availableDirections.index(of: "southeast") != nil {
            southeast?.draw(in: self.bounds)
        }
        
        if self.availableDirections.index(of: "southwest") != nil {
            southwest?.draw(in: self.bounds)
        }
        
        if self.availableDirections.index(of: "up") != nil {
            up?.draw(in: self.bounds)
        }
        
        if self.availableDirections.index(of: "down") != nil {
            down?.draw(in: self.bounds)
        }
        
        if self.availableDirections.index(of: "out") != nil {
            out?.draw(in: self.bounds)
        }
    }
}
