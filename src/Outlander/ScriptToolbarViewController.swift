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
    }
    
    func addScript(scriptName:String) {
        var btn = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 100, height: 25), pullsDown: true)
        btn.setButtonType(NSButtonType.SwitchButton)
        btn.menu = NSMenu()
        btn.menu?.addItem(createMenuItem(scriptName, title: scriptName, tag: 0))
        btn.menu?.addItem(createMenuItem(scriptName, title: "Resume", tag: 1))
        btn.menu?.addItem(createMenuItem(scriptName, title: "Pause", tag: 2))
        btn.menu?.addItem(createMenuItem(scriptName, title: "Abort", tag: 3))
        self.view.subviews.append(btn)
    }
    
    func createMenuItem(scriptName:String, title:String, tag:Int) -> NSMenuItem {
        var item = NSMenuItem()
        var attributes = [NSForegroundColorAttributeName: NSColor.whiteColor()]
        var titleString = NSAttributedString(string: title, attributes: attributes)
        item.attributedTitle = titleString
        item.tag = tag
        return item
    }
    
    func popUpSelectionChanged(notification:NSNotification) {
        if let menuItem = notification.userInfo?["MenuItem"] as? NSMenuItem {
            println("\(menuItem.title)")
        }
    }
    
    func save() {
    }
    
    func setContext(context:GameContext) {
    }
}
