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
    
    var mapLevel:Int = 0 {
        didSet {
            if oldValue != self.mapLevel {
                self.needsDisplay = true
            }
        }
    }

    var roomSize:CGFloat = 7.0

    var currentRoomId:String? = "162" {
        didSet {
            if oldValue != self.currentRoomId {
                self.needsDisplay = true
            }
        }
    }
    
    var currentRoomColor:NSColor = NSColor(hex:"#00ffff")
    
    var defaultRoomColor:NSColor = NSColor(hex:"#ffffff")
    var defaultPathColor:NSColor = NSColor(hex:"#000000")
    
    func setZone(mapZone:MapZone, rect:NSRect) {
        self.mapZone = mapZone
        self.rect = rect
        self.needsDisplay = true
    }
    
    override var flipped:Bool {
        get {
            return true
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        println("****redraw****")
//        NSColor(hex: "#ffcc66").setFill()
//        
//        NSRectFill(NSMakeRect(0, 0, self.frame.width, self.frame.height));
        
        if let zone = self.mapZone {
            
            var strokeWidth:CGFloat = 1.0
            
            NSBezierPath.setDefaultLineWidth(strokeWidth)
            NSBezierPath.setDefaultLineCapStyle(NSLineCapStyle.RoundLineCapStyle)
            
            var rooms = zone.rooms.filter { $0.position.z == self.mapLevel }
            
            for room in rooms {
                
                let point = self.translatePosition(room.position)
                
                self.defaultPathColor.setStroke()
                
                var hasDest = room.arcs.filter { countElements($0.destination) > 0 }
                
                for dest in hasDest {
                    var arc = zone.roomWithId(dest.destination)!
                    let arcPoint = self.translatePosition(arc.position)
                    
                    NSBezierPath.strokeLineFromPoint(point, toPoint: arcPoint)
                }
            }
            
            for room in rooms {
                
                if room.position.z == self.mapLevel {
                    
                    let point = self.translatePosition(room.position)
                    
                    //println("(\(room.position.x), \(room.position.y)) to \(point)")
                    
                    self.defaultPathColor.setStroke()

                    var outlineRect = NSMakeRect(point.x-(self.roomSize/2), point.y-(self.roomSize/2), self.roomSize, self.roomSize)
                    
                    var border = NSBezierPath()
                    border.appendBezierPathWithRect(outlineRect)
                    border.stroke()
                    
                    if room.id == self.currentRoomId {
                        self.currentRoomColor.setFill()
                    }
                    else if room.color != nil && room.color!.hasPrefix("#") {
        
                        NSColor(hex: room.color!).setFill()
                        
                    } else {
                        
                        self.defaultRoomColor.setFill()
                    }
                    
                    NSRectFill(NSMakeRect(
                        outlineRect.origin.x + (strokeWidth / 2.0),
                        outlineRect.origin.y + (strokeWidth / 2.0),
                        outlineRect.width - (strokeWidth/2.0 * 2.0),
                        outlineRect.height - (strokeWidth/2.0 * 2.0)
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
