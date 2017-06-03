//
//  VariablesViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 3/30/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

open class GlobalVariable : NSObject {
    var name:String {
        willSet {
            self.willChangeValue(forKey: "name")
        }
        didSet {
            self.didChangeValue(forKey: "name")
        }
    }
    
    var val:String {
        willSet {
            self.willChangeValue(forKey: "val")
        }
        didSet {
            self.didChangeValue(forKey: "val")
        }
    }
    
    init(_ name:String, _ val:String){
        self.name = name
        self.val = val
    }
    
    open override class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        if key == "name" || key == "val" {
            return true
        } else {
            return super.automaticallyNotifiesObservers(forKey: key)
        }
    }
}

open class VariablesViewController: NSViewController, SettingsView, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    
    fileprivate var _context:GameContext?
    fileprivate var _appSettingsLoader:AppSettingsLoader?
    
    fileprivate var _globalVars:[GlobalVariable] = []
    
    open var selectedItem:GlobalVariable? {
        willSet {
            self.willChangeValue(forKey: "selectedItem")
        }
        didSet {
            self.didChangeValue(forKey: "selectedItem")
        }
    }
    
    open override class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        if key == "selectedItem" {
            return true
        } else {
            return super.automaticallyNotifiesObservers(forKey: key)
        }
    }
    
    open override func awakeFromNib() {
        self.reloadVars()
    }
    
    open func save() {
    }
    
    open func setContext(_ context:GameContext) {
        _context = context
        _appSettingsLoader = AppSettingsLoader(context: _context)
    }
    
    fileprivate func reloadVars(){
        let vars = _context!.globalVars.copyValues()
      
        _globalVars = []
        
        for key in vars! {
            let global = GlobalVariable(key.0 as! String, key.1 as! String)
            _globalVars.append(global)
        }
        
        _globalVars = _globalVars.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name)
                == ComparisonResult.orderedAscending
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func addRemoveAction(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
           
            let global = GlobalVariable("", "")
            
            _globalVars.append(global)
            
            let count = _globalVars.count - 1;
            
            let idx = IndexSet(integer: count)
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(idx, byExtendingSelection: false)
            self.tableView.scrollRowToVisible(idx.first!)
        } else {
            
            let count = _globalVars.count
            
            if self.tableView.selectedRow < 0
                || self.tableView.selectedRow >= count {
                return
            }
            
            let item = self.selectedItem!
            
            self.selectedItem = nil;
            
            _context!.globalVars.removeObject(forKey: item.name)
            
            self.reloadVars()
        }
    }
    
    // MARK: NSTableViewDataSource
    
    open func numberOfRows(in tableView: NSTableView) -> Int {
        return _globalVars.count;
    }
    
    open func tableViewSelectionDidChange(_ notification:Notification) {
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < _globalVars.count) {
                
                self.selectedItem = _globalVars[selectedRow]
        }
        else {
            self.selectedItem = nil;
        }
    }
    
    open func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
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
