//
//  AliasesViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 3/29/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

open class AliasesViewController: NSViewController, SettingsView, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var aliasTextField: NSTextField!
    fileprivate var _context:GameContext?
    fileprivate var _appSettingsLoader:AppSettingsLoader?
    
    open var selectedItem:Alias? {
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
    
    override open func awakeFromNib() {
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }
    
    open override func controlTextDidChange(_ obj: Notification) {
        if let item = self.selectedItem {
            let textField = obj.object as! NSTextField
            if(textField.tag == 1) {
                item.pattern = textField.stringValue
            } else {
                item.replace = textField.stringValue
            }
            self.tableView.reloadData()
        }
    }
    
    open func save() {
        _appSettingsLoader!.saveAliases()
    }
    
    open func setContext(_ context:GameContext) {
        _context = context
        _appSettingsLoader = AppSettingsLoader(context: _context)
    }
    
    @IBAction func addRemoveAction(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            let alias = Alias()
            _context!.aliases.add(alias)
           
            let idx = IndexSet(integer: _context!.aliases.count() - 1)
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(idx, byExtendingSelection: false)
            self.tableView.scrollRowToVisible(idx.first!)
        } else {
            
            if self.tableView.selectedRow < 0 || self.tableView.selectedRow >= _context!.aliases.count() {
                return
            }
            
            self.selectedItem = nil;
            
            let item: Alias = _context!.aliases.object(at: self.tableView.selectedRow) as! Alias
            _context!.aliases.remove(item)
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: NSTableViewDataSource

    open func numberOfRows(in tableView: NSTableView) -> Int {
        return _context!.aliases.count()
    }
    
    open func tableViewSelectionDidChange(_ notification:Notification) {
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < _context!.aliases.count()) {
                self.selectedItem =
                    _context!.aliases.object(at: selectedRow) as? Alias;
        }
        else {
            self.selectedItem = nil;
        }
    }
    
    open func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        if (row >= _context!.aliases.count()){
            return "";
        }
        
        let item = _context!.aliases.object(at: row) as! Alias
        
        if(tableColumn!.identifier == "alias") {
            return item.pattern
        }
        
        return item.replace
    }
}
