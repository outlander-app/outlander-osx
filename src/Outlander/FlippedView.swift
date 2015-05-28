//
//  FlippedView.swift
//  Outlander
//
//  Created by Joseph McBride on 5/25/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

class FlippedView : NSView {
    override var flipped:Bool {
        get {
            return true
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
//        NSColor.blackColor().setFill()
//        
//        NSRectFill(dirtyRect)
        
        super.drawRect(dirtyRect)
    }
}