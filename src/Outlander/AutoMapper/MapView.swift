//
//  MapView.swift
//  Outlander
//
//  Created by Joseph McBride on 4/4/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

class MapView: NSView {
    
    private var mapZone:MapZone?
    private var rect:NSRect?

    var currentRoomId:String? = "162"
    
    func setZone(mapZone:MapZone, rect:NSRect) {
        self.mapZone = mapZone
        self.needsDisplay = true
        self.rect = rect
    }
    
    override var flipped:Bool {
        get {
            return true
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
//        NSColor(hex: "#ffcc66").setFill()
//        
//        NSRectFill(NSMakeRect(0, 0, self.frame.width, self.frame.height));
        
        if let zone = self.mapZone {
            
            var strokeWidth:CGFloat = 1.0
            
            NSBezierPath.setDefaultLineWidth(strokeWidth)
            NSBezierPath.setDefaultLineCapStyle(NSLineCapStyle.RoundLineCapStyle)
            
            var rooms = zone.rooms.filter { $0.position.z == 0 }
            
            for room in rooms {
                
                let point = self.translatePosition(room.position)
                
                NSColor(hex: "#000000").setStroke()
                
                var hasDest = room.arcs.filter { countElements($0.destination) > 0 }
                
                for dest in hasDest {
                    var arc = zone.roomWithId(dest.destination)!
                    let arcPoint = self.translatePosition(arc.position)
                    
                    NSBezierPath.strokeLineFromPoint(point, toPoint: arcPoint)
                }
            }
            
            for room in rooms {
                
                if room.position.z == 0 {
                    
                    let point = self.translatePosition(room.position)
                    
                    println("(\(room.position.x), \(room.position.y)) to \(point)")
                    
                    NSColor(hex: "#000000").setStroke()

                    var size:CGFloat = 7.0
                    
                    var rect = NSMakeRect(point.x-(size/2), point.y-(size/2), size, size)
                    
                    var border = NSBezierPath()
                    border.appendBezierPathWithRect(rect)
                    border.stroke()
                    
                    if room.id == self.currentRoomId {
                        NSColor(hex: "#00ffff").setFill()
                    }
                    else if room.color != nil && room.color!.hasPrefix("#") {
        
                        NSColor(hex: room.color!).setFill()
                        
                    } else {
                        
                        NSColor(hex: "#ffffff").setFill()
                    }
                    
                    NSRectFill(NSMakeRect(
                        rect.origin.x + (strokeWidth / 2.0),
                        rect.origin.y + (strokeWidth / 2.0),
                        rect.width - (strokeWidth/2.0 * 2.0),
                        rect.height - (strokeWidth/2.0 * 2.0)
                    ));
                }
            }
            
        }
        
        super.drawRect(dirtyRect)
    }
    
    func translatePosition(point:MapPosition) -> CGPoint {
        
        var x = point.x
        var y = point.y
        
        var centerX = self.rect!.origin.x
        var centerY = self.rect!.origin.y;
        
        var resX = CGFloat(x) + centerX
        var resY = CGFloat(y) + centerY
        
        return CGPoint(x: resX, y: resY)
    }
}
