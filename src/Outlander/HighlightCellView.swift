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
    
    var selected:Bool = false
    var backgroundColor:NSColor? {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
        var strokeWidth:CGFloat = 3.5
        
        NSBezierPath.setDefaultLineWidth(strokeWidth)
        NSBezierPath.setDefaultLineCapStyle(NSLineCapStyle.RoundLineCapStyle)
        
        if let bg = backgroundColor {
            bg.setFill()
            
            NSRectFill(self.bounds)
        }
        
        if self.selected {
            NSColor(hex: "#3399ff").setStroke()
            var border = NSBezierPath()
            var borderRect = NSMakeRect(self.bounds.origin.x, self.bounds.origin.y, self.bounds.width-2, self.bounds.height)
            border.appendBezierPathWithRect(borderRect)
            border.stroke()
        }
        
        super.drawRect(dirtyRect)
    }
}
