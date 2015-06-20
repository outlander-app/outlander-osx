//
//  TriggersViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 6/9/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

public class TriggersViewController: NSViewController, SettingsView, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    private var _context:GameContext?
    private var _appSettingsLoader:AppSettingsLoader?
   
    public var selectedItem:Trigger? {
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

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
    }
    
    public override func controlTextDidChange(obj: NSNotification) {
        if let item = self.selectedItem {
            var textField = obj.object as! NSTextField
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
    
    public func save() {
        _appSettingsLoader!.saveTriggers()
    }

    public func setContext(context:GameContext) {
        _context = context
        _appSettingsLoader = AppSettingsLoader(context: _context)
    }

    @IBAction func addRemoveAction(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            var trigger = Trigger("", "", "")
            _context!.triggers.addObject(trigger)
            
            let idx = NSIndexSet(index: _context!.triggers.count() - 1)
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(idx, byExtendingSelection: false)
            self.tableView.scrollRowToVisible(idx.firstIndex)
        } else {
            
            if self.tableView.selectedRow < 0 || self.tableView.selectedRow >= _context!.triggers.count() {
                return
            }
            
            self.selectedItem = nil;
            
            var item:Trigger = _context!.triggers.objectAtIndex(self.tableView.selectedRow) as! Trigger
            _context!.triggers.removeObject(item)
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: NSTableViewDataSource
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return _context!.triggers.count()
    }
    
    public func tableViewSelectionDidChange(notification:NSNotification) {
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < _context!.triggers.count()) {
                self.selectedItem =
                    _context!.triggers.objectAtIndex(selectedRow) as? Trigger;
        }
        else {
            self.selectedItem = nil;
        }
    }
    
    public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        if (row >= _context!.triggers.count()){
            return "";
        }
        
        var item = _context!.triggers.objectAtIndex(row) as! Trigger
        
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
