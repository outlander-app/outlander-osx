//
//  GameViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 6/22/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation

class GameViewController : NSViewController {

    func applyYogaLayout() {
        self.view.yoga.width = YGValue(self.view.frame.size.width)
        self.view.yoga.height = YGValue(self.view.frame.size.height)
        self.view.yoga.applyLayout(preservingOrigin: true)
        print("apply layout")
    }

    override func loadView() {
        self.view = YogaView()
    }

    override func viewDidLoad() {
        let root = self.view as! YogaView
        root.key = "root"
        root.backgroundColor = NSColor.redColor()

        root.configureLayout { (layout) in
            layout.isEnabled = true
            layout.width = YGValue(root.frame.size.width)
            layout.height = YGValue(root.frame.size.height)
            layout.alignItems = .FlexStart
            layout.justifyContent = .FlexStart
            layout.flexDirection = .Column
            layout.position = .Relative
        }

        let child1 = YogaView()
        child1.key = "child 1"
        child1.backgroundColor = NSColor.blueColor()
        child1.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flexGrow = 0
            layout.alignSelf = .Stretch
            layout.minHeight = YGValue(40)
        }
        root.addSubview(child1)

        let child2 = YogaView()
        child2.key = "child 2"
        child2.backgroundColor = NSColor.greenColor()
        child2.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flexGrow = 1
            layout.alignSelf = .Stretch
            layout.height = YGValue(40)
        }
        root.addSubview(child2)

        let child3 = YogaView()
        child3.key = "child 3"
        child3.backgroundColor = NSColor.purpleColor()
        child3.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flexGrow = 0
            layout.alignSelf = .Stretch
            layout.minHeight = YGValue(40)
        }
        root.addSubview(child3)

        child3.addSubview(Container([
            TextView("abcd 123"),
            TextView("another").configureLayout2({ layout in
                layout.paddingLeft = YGValue(20)
            })
        ]))

        root.yoga.applyLayout(preservingOrigin: false)
    }
}
