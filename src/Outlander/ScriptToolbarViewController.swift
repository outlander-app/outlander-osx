//
//  ScriptToolbarViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 5/25/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

class ScriptToolbarViewController: NSViewController, SettingsView {
    
    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "popUpSelectionChanged:", name: NSMenuDidSendActionNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addScript("collect")
        self.addScript("idle")
    }
    
    func addScript(scriptName:String) {
        let viewCount = self.view.subviews.count
        let width = 75
        
        var btn = NSPopUpButton(frame: NSRect(x: viewCount * width, y: 0, width: width, height: 25), pullsDown: true)
        btn.setButtonType(NSButtonType.PushOnPushOffButton)
        btn.menu = NSMenu()
        btn.menu?.title = scriptName
        btn.menu?.addItem(createMenuItem(scriptName, title: scriptName, textColor: NSColor.whiteColor()))
        btn.menu?.addItem(createMenuItem(scriptName, title: "Resume", textColor: NSColor.blackColor()))
        btn.menu?.addItem(createMenuItem(scriptName, title: "Pause", textColor: NSColor.blackColor()))
        btn.menu?.addItem(createMenuItem(scriptName, title: "Abort", textColor: NSColor.blackColor()))
        self.view.subviews.append(btn)
    }
    
    func createMenuItem(scriptName:String, title:String, textColor:NSColor) -> NSMenuItem {
        var item = NSMenuItem()
        var attributes = [NSForegroundColorAttributeName: textColor]
        var titleString = NSAttributedString(string: title, attributes: attributes)
        item.attributedTitle = titleString
        return item
    }
    
    func popUpSelectionChanged(notification:NSNotification) {
        if let menuItem = notification.userInfo?["MenuItem"] as? NSMenuItem {
            println("\(menuItem.menu?.title): \(menuItem.attributedTitle?.string)")
        }
    }
    
    func save() {
    }
    
    func setContext(context:GameContext) {
    }
}
