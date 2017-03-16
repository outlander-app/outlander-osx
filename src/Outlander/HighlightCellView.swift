//
//  HighlightCellView.swift
//  Outlander
//
//  Created by Joseph McBride on 5/16/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

class HighlightCellView: NSView {
    
    @IBOutlet weak var colorField: NSTextField!
    @IBOutlet weak var pattern: NSTextField!
    @IBOutlet weak var filterClass: NSTextField!
    
    var selected:Bool = false {
        didSet {
            self.needsDisplay = true
        }
    }
    
    var backgroundColor:NSColor? {
        didSet {
            self.needsDisplay = true
        }
    }

    var selectedColor:NSColor = NSColor(hex:"#3399ff") {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
        let strokeWidth:CGFloat = 3.5
        
        NSBezierPath.setDefaultLineWidth(strokeWidth)
        NSBezierPath.setDefaultLineCapStyle(NSLineCapStyle.RoundLineCapStyle)
        
        if let bg = backgroundColor {
            bg.setFill()
            
            NSRectFill(self.bounds)
        }
        
        if self.selected {
            self.selectedColor.setStroke()
            let border = NSBezierPath()
            let borderRect = NSMakeRect(self.bounds.origin.x, self.bounds.origin.y, self.bounds.width-2, self.bounds.height)
            border.appendBezierPathWithRect(borderRect)
            border.stroke()
        }
        
        super.drawRect(dirtyRect)
    }
}
