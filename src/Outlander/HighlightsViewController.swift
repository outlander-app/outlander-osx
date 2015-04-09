//
//  HighlightsViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 3/31/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

public class HighlightsViewController: NSViewController, SettingsView, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var colorWell: NSColorWell!
    private var _context:GameContext?
    private var _appSettingsLoader:AppSettingsLoader?
    
    public var selectedItem:Highlight? {
        willSet {
            self.willChangeValueForKey("selectedItem")
        }
        didSet {
            self.didChangeValueForKey("selectedItem")
            
            if let item = selectedItem {
                if count(item.color) > 0 {
                    colorWell.color = NSColor(hex: item.color)
                }
            }
        }
    }
    
    public override class func automaticallyNotifiesObserversForKey(key: String) -> Bool {
        if key == "selectedItem" {
            return true
        } else {
            return super.automaticallyNotifiesObserversForKey(key)
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    public override func awakeFromNib() {
        self.tableView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
    }
    
    public func save() {
        _appSettingsLoader!.saveHighlights()
    }
    
    public func setContext(context:GameContext) {
        _context = context
        _appSettingsLoader = AppSettingsLoader(context: _context)
    }

    public override func controlTextDidChange(obj: NSNotification) {
        if let item = self.selectedItem {
            
            var textField = obj.object as! NSTextField
            
            if(textField.tag == 1) {
                
                item.pattern = textField.stringValue
                
            } else {
                
                item.color = textField.stringValue
                
                if count(item.color) > 0 {
                    colorWell.color = NSColor(hex: item.color)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addRemoveAction(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            var highlight = Highlight()
            highlight.color = "#0000ff"
            highlight.pattern = ""
            _context!.highlights.addObject(highlight)
           
            let idx = NSIndexSet(index: _context!.highlights.count() - 1)
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(idx, byExtendingSelection: false)
            self.tableView.scrollRowToVisible(idx.firstIndex)
        } else {
            
            if self.tableView.selectedRow < 0 || self.tableView.selectedRow >= _context!.highlights.count() {
                return
            }
            
            self.selectedItem = nil;
            
            var item: Highlight = _context!.highlights.objectAtIndex(self.tableView.selectedRow) as! Highlight
            _context!.highlights.removeObject(item)
            
            self.tableView.reloadData()
        }
    }

    // MARK: NSTableViewDataSource

    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return _context!.highlights.count()
    }
    
    public func tableViewSelectionDidChange(notification:NSNotification) {
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < _context!.highlights.count()) {
                self.selectedItem =
                    _context!.highlights.objectAtIndex(selectedRow) as? Highlight;
        }
        else {
            self.selectedItem = nil;
        }
    }
    
    public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        
        if (row >= _context!.highlights.count()){
            return "";
        }
        
        var item = _context!.highlights.objectAtIndex(row) as! Highlight
        
        if(tableColumn!.identifier == "color") {
            return item.color
        }
        
        return item.pattern
    }
}
