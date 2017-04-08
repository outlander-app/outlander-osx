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
    
    fileprivate var context: GameContext?
    fileprivate var font: String = "Menlo"
    fileprivate var fontSize: CGFloat = 12

    func handle(_ token:String, data:Dictionary<String, AnyObject>) {
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
    
    func resumeScript(_ scriptName:String) {
        for view in self.view.subviews {
            if let button = view as? NSPopUpButton {
                if button.menu?.title == scriptName || scriptName == "all" {
                    button.menu?.item(at: 0)?.image = NSImage(named: "NSStatusAvailable")
                }
            }
        }
    }
    
    func pauseScript(_ scriptName:String) {
        for view in self.view.subviews {
            if let button = view as? NSPopUpButton {
                if button.menu?.title == scriptName || scriptName == "all" {
                    button.menu?.item(at: 0)?.image = NSImage(named: "NSStatusPartiallyAvailable")
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
    
    func removeScript(_ scriptName:String) {
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
                    width = NSString(string: title).size(withAttributes: [NSFontAttributeName: NSFont(name: self.font, size: self.fontSize)!]).width
                    width += 50
                }
                button.frame = NSRect(x: offset, y: 0, width: width, height: 25)
                offset += button.frame.width
            }
        }
    }
    
    func addScript(_ scriptName:String) {

        let buttonFont = NSFont(name: self.font, size: self.fontSize)!

        let frame = NSRect(x: 0, y: 0, width: 75, height: 25)
        
        let btn = NSPopUpButton(frame: frame, pullsDown: true)
        btn.setButtonType(NSButtonType.switch)
        btn.font = buttonFont
        btn.menu = NSMenu(title: scriptName)
        btn.menu?.addItem(createMenuItem(scriptName, textColor: NSColor.white))
        btn.menu?.item(at: 0)?.image = NSImage(named: "NSStatusAvailable")
        btn.menu?.addItem(createMenuItem("Resume", textColor: NSColor.black))
        btn.menu?.item(at: 1)?.image = NSImage(named: "NSStatusAvailable")
        btn.menu?.addItem(createMenuItem("Pause", textColor: NSColor.black))
        btn.menu?.item(at: 2)?.image = NSImage(named: "NSStatusPartiallyAvailable")
        btn.menu?.addItem(createMenuItem("Abort", textColor: NSColor.black))
        btn.menu?.item(at: 3)?.image = NSImage(named: "NSStatusUnavailable")

        btn.menu?.insertItem(NSMenuItem.separator(), at: 4)

        let debugMenu = createMenuItem("Debug", textColor: NSColor.black)
        debugMenu.submenu = NSMenu(title: scriptName)
        debugMenu.submenu?.addItem(createSubMenuItem("0. Debug off", textColor: NSColor.black, tag: ScriptLogLevel.none))
        debugMenu.submenu?.addItem(createSubMenuItem("1. Goto, gosub, return, labels", textColor: NSColor.black, tag: ScriptLogLevel.gosubs))
        debugMenu.submenu?.addItem(createSubMenuItem("2. Pause, wait, waitfor, move", textColor: NSColor.black, tag: ScriptLogLevel.wait))
        debugMenu.submenu?.addItem(createSubMenuItem("3. If evaluations", textColor: NSColor.black, tag: ScriptLogLevel.if))
        debugMenu.submenu?.addItem(createSubMenuItem("4. Math, variables", textColor: NSColor.black, tag: ScriptLogLevel.vars))
        debugMenu.submenu?.addItem(createSubMenuItem("5. Actions", textColor: NSColor.black, tag: ScriptLogLevel.actions))
        btn.menu?.addItem(debugMenu)
        btn.menu?.item(at: 5)?.image = NSImage(named: "NSStatusNone")
        
        btn.menu?.addItem(createMenuItem("Trace", textColor: NSColor.black))
        btn.menu?.item(at: 6)?.image = NSImage(named: "NSStatusNone")

        btn.menu?.addItem(createMenuItem("Vars", textColor: NSColor.black))
        btn.menu?.item(at: 7)?.image = NSImage(named: "NSStatusNone")

        self.view.subviews.append(btn)

        NotificationCenter.default.addObserver(self, selector: #selector(ScriptToolbarViewController.popUpSelectionChanged(_:)), name: NSNotification.Name.NSMenuDidSendAction, object: btn.menu)

        self.updateButtonFrames()
    }
    
    func debugMenuItemSelection(_ target:NSMenuItem) {
        let level = ScriptLogLevel(rawValue: target.tag) ?? ScriptLogLevel.none
        let scriptName = target.menu!.title
        self.context?.events.publish("script", data: ["target":scriptName as AnyObject, "action":"debug" as AnyObject, "param":"\(level.rawValue)" as AnyObject])
    }
    
    func createMenuItem(_ title:String, textColor:NSColor) -> NSMenuItem {
        let item = NSMenuItem()
        let titleString = createTitleString(title, textColor: textColor)
        item.attributedTitle = titleString
        return item
    }
    
    func createSubMenuItem(_ title:String, textColor:NSColor, tag:ScriptLogLevel) -> NSMenuItem {
        let item = NSMenuItem(title: "", action: #selector(ScriptToolbarViewController.debugMenuItemSelection(_:)), keyEquivalent: "")
        item.target = self
        let titleString = createTitleString(title, textColor: textColor)
        item.attributedTitle = titleString
        item.tag = tag.rawValue
        return item
    }
    
    func createTitleString(_ title:String, textColor:NSColor) -> NSAttributedString {
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = NSFont(name: self.font, size: self.fontSize)
        
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = NSLineBreakMode.byTruncatingTail
        attributes[NSParagraphStyleAttributeName] = style
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func popUpSelectionChanged(_ notification:Notification) {
        if let menuItem = notification.userInfo?["MenuItem"] as? NSMenuItem {
            let action = menuItem.attributedTitle!.string.lowercased()
            self.context?.events.publish("script", data: ["target":menuItem.menu!.title as AnyObject, "action":action as AnyObject])
        }
    }
    
    func save() {
    }

    func setContext(_ context:GameContext) {
        self.context = context
        
        _ = self.context?.events.subscribe(self, token: "script:add")
        _ = self.context?.events.subscribe(self, token: "script:resume")
        _ = self.context?.events.subscribe(self, token: "script:pause")
        _ = self.context?.events.subscribe(self, token: "script:remove")
        _ = self.context?.events.subscribe(self, token: "script:removeAll")
        _ = self.context?.events.subscribe(self, token: "script:debug")
    }
}
