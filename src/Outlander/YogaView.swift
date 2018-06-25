//
//  YogaView.swift
//  Outlander
//
//  Created by Joseph McBride on 6/22/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation

extension NSView {
    var backgroundColor: NSColor? {

        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(CGColor: colorRef)
            } else {
                return nil
            }
        }

        set {

            dispatch_async(dispatch_get_main_queue(), {
                self.wantsLayer = true
                self.layer?.backgroundColor = newValue?.CGColor
            })
        }
    }

    func configureLayout2(config:(YGLayout)->Void) -> NSView {
        self.configureLayout { (layout) in
            config(layout)
        }
        return self
    }
}

class YogaView : NSView {

    var key:String = ""
    var borderColor:CGColorRef?
    var borderWidth:CGFloat = 0.0

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        self.autoresizingMask = [.ViewHeightSizable, .ViewWidthSizable]
    }

    override var flipped:Bool {
        get {
            return true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }

    override func updateLayer() {
        super.updateLayer()
    }
}

class Container : YogaView {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(_ subViews:[NSView]) {
        super.init()

        self.configureLayout { layout in
            layout.isEnabled = true
            layout.flexGrow = 1
            layout.flexDirection = .Row
            layout.justifyContent = .FlexStart
            layout.alignItems = .Stretch
            layout.alignSelf = .Auto
            layout.alignContent = .Stretch
        }

        for view in subViews {
            view.configureLayout { layout in
                layout.isEnabled = true
            }
            self.addSubview(view)
        }
    }
}

class TextView : NSTextField {

    var text:String? {
        didSet {
            self.stringValue = self.text ?? ""
        }
    }
    
    init(_ string:String?) {
        self.text = string
        super.init(frame: NSRect(x: 0, y: 0, width: 100, height: 20))

        self.stringValue = string ?? ""

        self.bezeled = false
        self.drawsBackground = true
        self.backgroundColor = NSColor.yellowColor()
        self.editable = false
        self.selectable = true
        self.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.cell?.wraps = true
        self.alignment = NSTextAlignment.Center

        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setLayout() {
        self.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .Row
            layout.alignItems = .Stretch
            layout.alignSelf = .Center
            layout.alignContent = .Stretch
            layout.justifyContent = .FlexStart
        }
    }
}
