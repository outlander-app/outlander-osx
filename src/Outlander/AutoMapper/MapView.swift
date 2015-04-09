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
    private var trackingArea:NSTrackingArea?
    private var nodeLookup:[NSValue:String] = [:]
    
    var mapLevel:Int = 0 {
        didSet {
            if oldValue != self.mapLevel {
                self.nodeLookup = [:]
                self.needsDisplay = true
            }
        }
    }

    var roomSize:CGFloat = 7.0

    var currentRoomId:String? = "" {
        didSet {
            if oldValue != self.currentRoomId {
                self.redrawRoom(oldValue)
                self.redrawRoom(self.currentRoomId)
            }
        }
    }
    
    var currentRoomColor:NSColor = NSColor(hex:"#990099")
    
    var defaultRoomColor:NSColor = NSColor(hex:"#ffffff")
    var defaultPathColor:NSColor = NSColor(hex:"#000000")
    
    var nodeHover:((MapNode?)->Void)?
    
    
    func setZone(mapZone:MapZone, rect:NSRect) {
        self.mapZone = mapZone
        self.rect = rect
        self.nodeLookup = [:]
        
        self.trackingArea = createTrackingArea()
        self.addTrackingArea(self.trackingArea!)
        
        self.needsDisplay = true
    }
    
    override var flipped:Bool {
        get {
            return true
        }
    }
    
    override func updateTrackingAreas() {
        
        if self.trackingArea != nil {
            self.removeTrackingArea(self.trackingArea!)
        }
        
        self.trackingArea = createTrackingArea()
        self.addTrackingArea(self.trackingArea!)
        
        super.updateTrackingAreas()
    }
    
    func createTrackingArea() -> NSTrackingArea {
        return NSTrackingArea(
            rect: self.bounds,
            options: NSTrackingAreaOptions.ActiveInKeyWindow|NSTrackingAreaOptions.MouseMoved,
            owner: self,
            userInfo: nil)
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        
        let globalLocation = NSEvent.mouseLocation()
        let windowLocation = self.window!.convertRectFromScreen(NSRect(x: globalLocation.x, y: globalLocation.y, width: 0, height: 0))
        let viewLocation = self.convertPoint(windowLocation.origin, fromView: nil)
        
        self.lastMousePosition = viewLocation
        
        self.debouceLookupRoom()
    }
    
    var lastMousePosition:CGPoint?
    var debounceTimer:NSTimer?
    
    func debouceLookupRoom() {
        if let timer = debounceTimer {
            timer.invalidate()
        }
        debounceTimer = NSTimer(timeInterval: 0.07, target: self, selector: Selector("lookupRoom"), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(debounceTimer!, forMode: "NSDefaultRunLoopMode")
    }
    
    func lookupRoom() {
        
        let point = self.lastMousePosition!
        
        var room:MapNode?
        
        for (key,value) in self.nodeLookup {
            if key.rectValue.contains(point) {
                
                room = self.mapZone?.roomWithId(value)
                
                break
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            println("********lookup room********* \(room?.name)")
            self.nodeHover?(room)
        })
    }
    
    func redrawRoom(id:String?) {
        if let roomId = id {
            
            if let room = self.mapZone?.roomWithId(roomId) {
                var point = self.translatePosition(room.position)
                
                var outlineRect = NSMakeRect(point.x-(self.roomSize/2), point.y-(self.roomSize/2), self.roomSize, self.roomSize)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.setNeedsDisplayInRect(outlineRect)
                })
            }
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        println("****redraw**** \(dirtyRect)")
//        NSColor(hex: "#ffcc66").setFill()
//        
//        NSRectFill(NSMakeRect(0, 0, self.frame.width, self.frame.height));
        
        if let zone = self.mapZone {
            
            var strokeWidth:CGFloat = 0.5
            
            NSBezierPath.setDefaultLineWidth(strokeWidth)
            NSBezierPath.setDefaultLineCapStyle(NSLineCapStyle.RoundLineCapStyle)
            
            var rooms = zone.rooms.filter { $0.position.z == self.mapLevel }
            
            for room in rooms {
                
                let point = self.translatePosition(room.position)
                
                self.defaultPathColor.setStroke()
                
                var hasDest = room.arcs.filter { count($0.destination) > 0 }
                
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
                    
                    let loc = NSValue(rect: outlineRect)
                    
                    self.nodeLookup[loc] = room.id
                    
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
