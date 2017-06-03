//
//  TriggersViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 6/9/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

open class TriggersViewController: NSViewController, SettingsView, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    fileprivate var _context:GameContext?
    fileprivate var _appSettingsLoader:AppSettingsLoader?
   
    open var selectedItem:Trigger? {
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

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }
    
    open override func controlTextDidChange(_ obj: Notification) {
        if let item = self.selectedItem {
            let textField = obj.object as! NSTextField
            if(textField.tag == 1) {
                item.trigger = textField.stringValue
            }
            else if(textField.tag == 2) {
                item.action = textField.stringValue
            } else {
                item.actionClass = textField.stringValue
            }
            self.tableView.reloadData()
        }
    }
    
    open func save() {
        _appSettingsLoader!.saveTriggers()
    }

    open func setContext(_ context:GameContext) {
        _context = context
        _appSettingsLoader = AppSettingsLoader(context: _context)
    }

    @IBAction func addRemoveAction(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            let trigger = Trigger("", "", "")
            _context!.triggers.add(trigger)
            
            let idx = IndexSet(integer: _context!.triggers.count() - 1)
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(idx, byExtendingSelection: false)
            self.tableView.scrollRowToVisible(idx.first!)
        } else {
            
            if self.tableView.selectedRow < 0 || self.tableView.selectedRow >= _context!.triggers.count() {
                return
            }
            
            self.selectedItem = nil;
            
            let item:Trigger = _context!.triggers.object(at: self.tableView.selectedRow) as! Trigger
            _context!.triggers.remove(item)
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: NSTableViewDataSource
    open func numberOfRows(in tableView: NSTableView) -> Int {
        return _context!.triggers.count()
    }
    
    open func tableViewSelectionDidChange(_ notification:Notification) {
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < _context!.triggers.count()) {
                self.selectedItem =
                    _context!.triggers.object(at: selectedRow) as? Trigger;
        }
        else {
            self.selectedItem = nil;
        }
    }
    
    open func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        if (row >= _context!.triggers.count()){
            return "";
        }
        
        let item = _context!.triggers.object(at: row) as! Trigger
        
        var res:String = ""
        
        if(tableColumn!.identifier == "trigger") {
            res = item.trigger != nil ? item.trigger! : ""
        }
        else if(tableColumn!.identifier == "action") {
            res = item.action != nil ? item.action! : ""
        }
        else {
            res = item.actionClass != nil ? item.actionClass! : ""
        }
    
        return res
    }
}
