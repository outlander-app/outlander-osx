//
//  AliasesViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 3/29/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

public class AliasesViewController: NSViewController, SettingsView, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    private var _context:GameContext?
    private var _appSettingsLoader:AppSettingsLoader?
    
    public var selectedItem:Alias? {
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
    
    override public func awakeFromNib() {
        self.tableView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func save() {
        _appSettingsLoader!.saveAliases()
    }
    
    public func setContext(context:GameContext) {
        _context = context
        _appSettingsLoader = AppSettingsLoader(context: _context)
    }
    
    @IBAction func addRemoveAction(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            var alias = Alias()
            _context!.aliases.addObject(alias)
           
            let idx = NSIndexSet(index: _context!.aliases.count() - 1)
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(idx, byExtendingSelection: false)
            self.tableView.scrollRowToVisible(idx.firstIndex)
        } else {
            
            if self.tableView.selectedRow < 0 || self.tableView.selectedRow >= _context!.aliases.count() {
                return
            }
            
            self.selectedItem = nil;
            
            var item: Alias = _context!.aliases.objectAtIndex(self.tableView.selectedRow) as Alias
            _context!.aliases.removeObject(item)
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: NSTableViewDataSource

    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return _context!.aliases.count()
    }
    
    public func tableViewSelectionDidChange(notification:NSNotification) {
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < _context!.aliases.count()) {
                self.selectedItem =
                    _context!.aliases.objectAtIndex(selectedRow) as? Alias;
        }
        else {
            self.selectedItem = nil;
        }
    }
    
    public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        if (row >= _context!.aliases.count()){
            return "";
        }
        
        var item = _context!.aliases.objectAtIndex(row) as Alias
        
        if(tableColumn!.identifier == "alias") {
            return item.pattern
        }
        
        return item.replace
    }
}
