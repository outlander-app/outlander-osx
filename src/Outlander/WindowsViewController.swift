//
//  WindowsViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 4/9/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

class WindowsViewController: NSViewController, SettingsView {
    
    private var _context:GameContext?
    private var _appSettingsLoader:AppSettingsLoader?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func save() {
    }
    
    func setContext(context:GameContext) {
        _context = context
        _appSettingsLoader = AppSettingsLoader(context: _context)
    }
}
