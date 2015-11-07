//
//  VariablesViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 3/30/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

public class GlobalVariable : NSObject {
    var name:String {
        willSet {
            self.willChangeValueForKey("name")
        }
        didSet {
            self.didChangeValueForKey("name")
        }
    }
    
    var val:String {
        willSet {
            self.willChangeValueForKey("val")
        }
        didSet {
            self.didChangeValueForKey("val")
        }
    }
    
    init(_ name:String, _ val:String){
        self.name = name
        self.val = val
    }
    
    public override class func automaticallyNotifiesObserversForKey(key: String) -> Bool {
        if key == "name" || key == "val" {
            return true
        } else {
            return super.automaticallyNotifiesObserversForKey(key)
        }
    }
}

public class VariablesViewController: NSViewController, SettingsView, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    
    private var _context:GameContext?
    private var _appSettingsLoader:AppSettingsLoader?
    
    private var _globalVars:[GlobalVariable] = []
    
    public var selectedItem:GlobalVariable? {
        willSet {
            self.willChangeValueForKey("selectedItem")
        }
        didSet {
            self.didChangeValueForKey("selectedItem")
        }
    }
    
    public override class func automaticallyNotifiesObserversForKey(key: String) -> Bool {
        if key == "selectedItem" {
            return true
        } else {
            return super.automaticallyNotifiesObserversForKey(key)
        }
    }
    
    public override func awakeFromNib() {
        self.reloadVars()
    }
    
    public func save() {
    }
    
    public func setContext(context:GameContext) {
        _context = context
        _appSettingsLoader = AppSettingsLoader(context: _context)
    }
    
    private func reloadVars(){
        let vars = _context!.globalVars.copyValues()
      
        _globalVars = []
        
        for key in vars {
            let global = GlobalVariable(key.0 as! String, key.1 as! String)
            _globalVars.append(global)
        }
        
        _globalVars = _globalVars.sort {
            $0.name.localizedCaseInsensitiveCompare($1.name)
                == NSComparisonResult.OrderedAscending
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func addRemoveAction(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
           
            let global = GlobalVariable("", "")
            
            _globalVars.append(global)
            
            let count = _globalVars.count - 1;
            
            let idx = NSIndexSet(index: count)
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(idx, byExtendingSelection: false)
            self.tableView.scrollRowToVisible(idx.firstIndex)
        } else {
            
            let count = _globalVars.count
            
            if self.tableView.selectedRow < 0
                || self.tableView.selectedRow >= count {
                return
            }
            
            let item = self.selectedItem!
            
            self.selectedItem = nil;
            
            _context!.globalVars.removeObjectForKey(item.name)
            
            self.reloadVars()
        }
    }
    
    // MARK: NSTableViewDataSource
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return _globalVars.count;
    }
    
    public func tableViewSelectionDidChange(notification:NSNotification) {
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < _globalVars.count) {
                
                self.selectedItem = _globalVars[selectedRow]
        }
        else {
            self.selectedItem = nil;
        }
    }
    
    public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        if row >= _globalVars.count {
            return "";
        }
        
        let item = _globalVars[row]
        
        if(tableColumn!.identifier == "name") {
            return item.name
        }
        
        return item.val
    }
}
