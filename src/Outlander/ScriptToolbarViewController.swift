//
//  ScriptToolbarViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 5/25/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

@objc
class ScriptToolbarViewController: NSViewController, SettingsView, ISubscriber {
    
    private var context: GameContext?
    private var font: String = "Menlo"
    private var fontSize: CGFloat = 12

    func handle(token:String, data:Dictionary<String, AnyObject>) {
        mainThread { () -> () in
            if token == "script:add" {
                self.addScript(data["scriptName"] as! String)
            } else if token == "script:resume" {
                self.resumeScript(data["scriptName"] as! String)
            } else if token == "script:pause" {
                self.pauseScript(data["scriptName"] as! String)
            } else if token == "script:remove" {
                self.removeScript(data["scriptName"] as! String)
            } else if token == "script:removeAll" {
                self.removeAll()
            }
        }
    }
    
    func resumeScript(scriptName:String) {
        for view in self.view.subviews {
            if let button = view as? NSPopUpButton {
                if button.menu?.title == scriptName {
                    button.menu?.itemAtIndex(0)?.image = NSImage(named: "NSStatusAvailable")
                }
            }
        }
    }
    
    func pauseScript(scriptName:String) {
        for view in self.view.subviews {
            if let button = view as? NSPopUpButton {
                if button.menu?.title == scriptName {
                    button.menu?.itemAtIndex(0)?.image = NSImage(named: "NSStatusPartiallyAvailable")
                }
            }
        }
    }
    
    func removeAll() {
        for view in self.view.subviews {
            if let button = view as? NSPopUpButton {
                button.removeFromSuperview()
            }
        }
    }
    
    func removeScript(scriptName:String) {
        let startCount = self.view.subviews.count
        
        for view in self.view.subviews {
            if let button = view as? NSPopUpButton {
                if button.menu?.title == scriptName {
                    button.removeFromSuperview()
                }
            }
        }
        
        if self.view.subviews.count != startCount {
            updateButtonFrames()
        }
    }
    
    func updateButtonFrames() {
        var width: CGFloat = 125
        var offset: CGFloat = 0
        for view in self.view.subviews {
            if let button = view as? NSPopUpButton {
                if let title = button.menu?.title {
                    width = NSString(string: title).sizeWithAttributes([NSFontAttributeName: NSFont(name: self.font, size: self.fontSize)!]).width
                    width += 50
                }
                button.frame = NSRect(x: offset, y: 0, width: width, height: 25)
                offset += button.frame.width
            }
        }
    }
    
    func addScript(scriptName:String) {

        let buttonFont = NSFont(name: self.font, size: self.fontSize)!

        let frame = NSRect(x: 0, y: 0, width: 75, height: 25)
        
        let btn = NSPopUpButton(frame: frame, pullsDown: true)
        btn.setButtonType(NSButtonType.Switch)
        btn.font = buttonFont
        btn.menu = NSMenu(title: scriptName)
        btn.menu?.addItem(createMenuItem(scriptName, textColor: NSColor.whiteColor()))
        btn.menu?.itemAtIndex(0)?.image = NSImage(named: "NSStatusAvailable")
        btn.menu?.addItem(createMenuItem("Resume", textColor: NSColor.blackColor()))
        btn.menu?.itemAtIndex(1)?.image = NSImage(named: "NSStatusAvailable")
        btn.menu?.addItem(createMenuItem("Pause", textColor: NSColor.blackColor()))
        btn.menu?.itemAtIndex(2)?.image = NSImage(named: "NSStatusPartiallyAvailable")
        btn.menu?.addItem(createMenuItem("Abort", textColor: NSColor.blackColor()))
        btn.menu?.itemAtIndex(3)?.image = NSImage(named: "NSStatusUnavailable")
        
        let debugMenu = createMenuItem("Debug", textColor: NSColor.blackColor())
        debugMenu.submenu = NSMenu(title: scriptName)
        debugMenu.submenu?.addItem(createSubMenuItem("0. Debug off", textColor: NSColor.blackColor(), tag: ScriptLogLevel.None))
        debugMenu.submenu?.addItem(createSubMenuItem("1. Goto, gosub, return, labels", textColor: NSColor.blackColor(), tag: ScriptLogLevel.Gosubs))
        debugMenu.submenu?.addItem(createSubMenuItem("2. Pause, wait, waitfor, move", textColor: NSColor.blackColor(), tag: ScriptLogLevel.Wait))
        debugMenu.submenu?.addItem(createSubMenuItem("3. If evaluations", textColor: NSColor.blackColor(), tag: ScriptLogLevel.If))
        debugMenu.submenu?.addItem(createSubMenuItem("4. Math, variables", textColor: NSColor.blackColor(), tag: ScriptLogLevel.Vars))
        debugMenu.submenu?.addItem(createSubMenuItem("5. Actions", textColor: NSColor.blackColor(), tag: ScriptLogLevel.Actions))
        btn.menu?.addItem(debugMenu)
        btn.menu?.itemAtIndex(4)?.image = NSImage(named: "NSStatusNone")
        
        btn.menu?.addItem(createMenuItem("Vars", textColor: NSColor.blackColor()))
        btn.menu?.itemAtIndex(5)?.image = NSImage(named: "NSStatusNone")
        self.view.subviews.append(btn)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScriptToolbarViewController.popUpSelectionChanged(_:)), name: NSMenuDidSendActionNotification, object: btn.menu)

        self.updateButtonFrames()
    }
    
    func debugMenuItemSelection(target:NSMenuItem) {
        let level = ScriptLogLevel(rawValue: target.tag) ?? ScriptLogLevel.None
        let scriptName = target.menu!.title
        self.context?.events.publish("script", data: ["target":scriptName, "action":"debug", "param":"\(level.rawValue)"])
    }
    
    func createMenuItem(title:String, textColor:NSColor) -> NSMenuItem {
        let item = NSMenuItem()
        let titleString = createTitleString(title, textColor: textColor)
        item.attributedTitle = titleString
        return item
    }
    
    func createSubMenuItem(title:String, textColor:NSColor, tag:ScriptLogLevel) -> NSMenuItem {
        let item = NSMenuItem(title: "", action: #selector(ScriptToolbarViewController.debugMenuItemSelection(_:)), keyEquivalent: "")
        item.target = self
        let titleString = createTitleString(title, textColor: textColor)
        item.attributedTitle = titleString
        item.tag = tag.rawValue
        return item
    }
    
    func createTitleString(title:String, textColor:NSColor) -> NSAttributedString {
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = NSFont(name: self.font, size: self.fontSize)
        
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        attributes[NSParagraphStyleAttributeName] = style
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func popUpSelectionChanged(notification:NSNotification) {
        if let menuItem = notification.userInfo?["MenuItem"] as? NSMenuItem {
            let action = menuItem.attributedTitle!.string.lowercaseString
            self.context?.events.publish("script", data: ["target":menuItem.menu!.title, "action":action])
        }
    }
    
    func save() {
    }
    
    func setContext(context:GameContext) {
        self.context = context
        
        self.context?.events.subscribe(self, token: "script:add")
        self.context?.events.subscribe(self, token: "script:resume")
        self.context?.events.subscribe(self, token: "script:pause")
        self.context?.events.subscribe(self, token: "script:remove")
        self.context?.events.subscribe(self, token: "script:removeAll")
        self.context?.events.subscribe(self, token: "script:debug")
    }
}
