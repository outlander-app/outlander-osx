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
    @IBOutlet weak var backgroundColorWell: NSColorWell!
    private var _context:GameContext?
    private var _appSettingsLoader:AppSettingsLoader?
    
    public var selectedItem:Highlight? {
        willSet {
            self.willChangeValueForKey("selectedItem")
        }
        didSet {
            self.didChangeValueForKey("selectedItem")
            
            if let item = selectedItem {
                if item.color != nil && count(item.color) > 0 {
                    colorWell.color = NSColor(hex: item.color)
                }
                
                if item.backgroundColor != nil && count(item.backgroundColor) > 0 {
                    backgroundColorWell.color = NSColor(hex: item.backgroundColor)
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
        
        let nib = NSNib(nibNamed: "HighlightCellView", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib!, forIdentifier: "highlightCellView")
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

            } else if(textField.tag == 2) {
                
                item.backgroundColor = textField.stringValue
                
                if item.backgroundColor == nil {
                    item.backgroundColor = ""
                }
                
                if count(item.backgroundColor) > 0 {
                    backgroundColorWell.color = NSColor(hex: item.backgroundColor)
                }
                
            } else {
                
                item.color = textField.stringValue
                
                if item.color == nil {
                    item.color = ""
                }
                
                if count(item.color) > 0 {
                    colorWell.color = NSColor(hex: item.color)
                }
            }
            
            self.reloadSelectedRow()
        }
    }
    
    func reloadSelectedRow() {
        self.reloadTargetRowColumn(self.tableView.selectedRow, column: 0)
    }
    
    func reloadTargetRowColumn(row:Int, column:Int) {
        let indexSet = NSIndexSet(index: row)
        let columnSet = NSIndexSet(index: column)
        self.tableView.reloadDataForRowIndexes(indexSet, columnIndexes: columnSet)
    }
    
    @IBAction func addRemoveAction(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            var highlight = Highlight()
            highlight.color = "#0000ff"
            highlight.backgroundColor = ""
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
        
        var lastIdx = -1
        
        if let last = self.selectedItem {
            lastIdx = _context?.highlights.indexOfObject(last) ?? -1
        }
        
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < _context!.highlights.count()) {
                self.selectedItem =
                    _context!.highlights.objectAtIndex(selectedRow) as? Highlight;
        }
        else {
            self.selectedItem = nil;
        }
        
        if lastIdx > -1 {
            self.reloadTargetRowColumn(lastIdx, column: 0)
        }
        
        self.reloadSelectedRow()
    }
    
    public func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
        var cell = tableView.makeViewWithIdentifier("highlightCellView", owner: self) as? HighlightCellView
        
        if(row > -1 && row < _context!.highlights.count()) {
            
            if let hl = _context!.highlights.objectAtIndex(row) as? Highlight {
               
                cell?.pattern.stringValue = hl.pattern
                
                if hl.color != nil && count(hl.color) > 0 {
                    cell?.colorField.stringValue = hl.color
                    cell?.colorField.textColor = NSColor(hex: hl.color)
                    cell?.pattern.textColor = NSColor(hex: hl.color)
                } else {
                    cell?.colorField.stringValue = ""
                    cell?.colorField.textColor = nil
                    cell?.pattern.textColor = nil
                }
                
                if contains(self.tableView.selectedRowIndexes, row) {
                    cell?.selected = true
                } else {
                    cell?.selected = false
                }
                
                if hl.backgroundColor != nil && count(hl.backgroundColor) > 0 {
                    cell?.backgroundColor = NSColor(hex: hl.backgroundColor)
                } else {
                    cell?.backgroundColor = nil
                }
            }
        }
        
        return cell ?? NSView()
    }
}
