//
//  MapView.swift
//  Outlander
//
//  Created by Joseph McBride on 4/4/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

class MapView: NSView {
    
    fileprivate var mapZone:MapZone?
    var rect:NSRect?
    fileprivate var trackingArea:NSTrackingArea?
    fileprivate var nodeLookup:[NSValue:String] = [:]
    
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
    
    var zoneExitPathColor:NSColor = NSColor(hex:"#0000ff")
    
    var nodeHover:((MapNode?)->Void)?
    
    func getCurrentZoneId() -> String? {
        return self.mapZone?.id
    }
    
    func setZone(_ mapZone:MapZone, rect:NSRect) {
        self.mapZone = mapZone
        self.rect = rect
        self.nodeLookup = [:]
        
        self.trackingArea = createTrackingArea()
        self.addTrackingArea(self.trackingArea!)
        
        self.needsDisplay = true
    }
    
    override var isFlipped:Bool {
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
            options: [NSTrackingAreaOptions.activeInKeyWindow, NSTrackingAreaOptions.mouseMoved],
            owner: self,
            userInfo: nil)
    }
    
    override func mouseMoved(with theEvent: NSEvent) {
        
        let globalLocation = NSEvent.mouseLocation()
        let windowLocation = self.window!.convertFromScreen(NSRect(x: globalLocation.x, y: globalLocation.y, width: 0, height: 0))
        let viewLocation = self.convert(windowLocation.origin, from: nil)
        
        self.lastMousePosition = viewLocation
        
        self.debouceLookupRoom()
    }
    
    var lastMousePosition:CGPoint?
    var debounceTimer:Timer?
    
    func debouceLookupRoom() {
        if let timer = debounceTimer {
            timer.invalidate()
        }
        debounceTimer = Timer(timeInterval: 0.07, target: self, selector: #selector(MapView.lookupRoom), userInfo: nil, repeats: false)
        RunLoop.current.add(debounceTimer!, forMode: RunLoopMode(rawValue: "NSDefaultRunLoopMode"))
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
        
        DispatchQueue.main.async(execute: {
            self.nodeHover?(room)
        })
    }
    
    func redrawRoom(_ id:String?) {
        
        if let rect = self.rectForRoom(id) {
            
            DispatchQueue.main.async(execute: {
                self.setNeedsDisplay(rect)
            })
        }
    }
    
    func rectForRoom(_ id:String?) -> NSRect? {
        
        if let roomId = id {
            
            if let room = self.mapZone?.roomWithId(roomId) {
                let point = self.translatePosition(room.position)
                
                let outlineRect = NSMakeRect(point.x-(self.roomSize/2), point.y-(self.roomSize/2), self.roomSize, self.roomSize)
                return outlineRect
            }
        }
        
        return nil
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        if let zone = self.mapZone {
            
            var strokeWidth:CGFloat = 0.5
            
            NSBezierPath.setDefaultLineWidth(strokeWidth)
            NSBezierPath.setDefaultLineCapStyle(NSLineCapStyle.roundLineCapStyle)
            
            let rooms = zone.rooms.filter { $0.position.z == self.mapLevel }
            
            for room in rooms {
                
                let point = self.translatePosition(room.position)
                
                self.defaultPathColor.setStroke()
                
                let hasDest = room.arcs.filter { $0.destination.characters.count > 0 && !$0.hidden }
                
                for dest in hasDest {
                    let arc = zone.roomWithId(dest.destination)!
                    let arcPoint = self.translatePosition(arc.position)
                    
                    NSBezierPath.strokeLine(from: point, to: arcPoint)
                }
            }
            
            for room in rooms {
                
                if room.position.z == self.mapLevel {
                    
                    let point = self.translatePosition(room.position)
                    
                    //println("(\(room.position.x), \(room.position.y)) to \(point)")
                    
                    if let notes = room.notes, notes.range(of: ".xml") != nil {
                        strokeWidth = 1.5
                        NSBezierPath.setDefaultLineWidth(strokeWidth)
                        self.zoneExitPathColor.setStroke()
                    }
                    else {
                        strokeWidth = 0.5
                        NSBezierPath.setDefaultLineWidth(strokeWidth)
                        self.defaultPathColor.setStroke()
                    }

                    let outlineRect = NSMakeRect(point.x-(self.roomSize/2), point.y-(self.roomSize/2), self.roomSize, self.roomSize)
                    
                    let loc = NSValue(rect: outlineRect)
                    self.nodeLookup[loc] = room.id
                   
                    let border = NSBezierPath()
                    border.appendRect(outlineRect)
                    border.stroke()
                    
                    if room.id == self.currentRoomId {
                        self.currentRoomColor.setFill()
                    }
                    else if room.color != nil && room.color!.hasPrefix("#") {
        
                        NSColor(hex: room.color!).setFill()
                        
                    } else if let color = KnownColors.find(room.color) {
                        
                        color.setFill()
                        
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
            
            let labels = zone.labels.filter { $0.position.z == self.mapLevel }
            
            for label in labels {
                
                let point = self.translatePosition(label.position)
                
                let storage = NSTextStorage(string: label.text)
                storage.draw(at: point)
            }
            
        }
        
        super.draw(dirtyRect)
    }
    
    func translatePosition(_ point:MapPosition) -> CGPoint {
        
        let x = point.x
        let y = point.y
        
        let centerX = self.rect!.origin.x
        let centerY = self.rect!.origin.y;
        
        let resX = CGFloat(x) + centerX
        let resY = CGFloat(y) + centerY
        
        return CGPoint(x: resX, y: resY)
    }
}

open class KnownColors {
    
    static var colors:[String:String] = [
        "Aqua": "#00ffff",
        "Blue": "#0000ff",
        "Fuchsia": "#ff00cc",
        "Lime": "#00ff00",
        "Olive": "#999900",
        "Red": "#ff3300",
        "Yellow": "#ffff00"]

    static func find(_ color:String?) -> NSColor? {
        
        if color == nil {
            return nil
        }
        
        if let val = colors[color!] {
            return NSColor(hex: val)
        }
        
        return nil
    }
}
