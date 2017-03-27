//
//  HighlightsViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 3/31/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

open class HighlightsViewController: NSViewController, SettingsView, NSTableViewDataSource, NSSoundDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var colorWell: NSColorWell!
    @IBOutlet weak var backgroundColorWell: NSColorWell!
    @IBOutlet weak var soundButton: NSButton!

    fileprivate var _context:GameContext?
    fileprivate var _appSettingsLoader:AppSettingsLoader?
    fileprivate var _fileSystem:FileSystem?
    fileprivate var _sound:NSSound?
    
    open var selectedItem:Highlight? {
        willSet {
            self.willChangeValue(forKey: "selectedItem")
        }
        didSet {
            self.didChangeValue(forKey: "selectedItem")
            
            if let item = selectedItem {
                if item.color != nil && item.color!.characters.count > 0 {
                    colorWell.color = NSColor(hex: item.color!)
                } else {
                    colorWell.color = NSColor.black
                }
                
                if item.backgroundColor != nil && item.backgroundColor!.characters.count > 0 {
                    backgroundColorWell.color = NSColor(hex: item.backgroundColor!)
                } else {
                    backgroundColorWell.color = NSColor.black
                }
            }
        }
    }
    
    open override class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        if key == "selectedItem" {
            return true
        } else {
            return super.automaticallyNotifiesObservers(forKey: key)
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = NSNib(nibNamed: "HighlightCellView", bundle: Bundle.main)
        tableView.register(nib!, forIdentifier: "highlightCellView")
    }
    
    open override func awakeFromNib() {
        _fileSystem = LocalFileSystem()
        self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }
    
    open func save() {
        _appSettingsLoader!.saveHighlights()
        stopSound()
        removeSound()
    }
    
    open func setContext(_ context:GameContext) {
        _context = context
        _appSettingsLoader = AppSettingsLoader(context: _context)
    }

    open override func controlTextDidChange(_ obj: Notification) {
        if let item = self.selectedItem {
            
            let textField = obj.object as! NSTextField
            
            if(textField.tag == 1) {
                
                item.pattern = textField.stringValue

            } else if(textField.tag == 2) {
                
                item.backgroundColor = textField.stringValue
                
                if item.backgroundColor == nil {
                    item.backgroundColor = ""
                }
                
                if item.backgroundColor!.characters.count > 0 {
                    backgroundColorWell.color = NSColor(hex: item.backgroundColor!)
                }
                
            } else if textField.tag == 0 {

                item.color = textField.stringValue

                if item.color == nil {
                    item.color = ""
                }
                
                if item.color!.characters.count > 0 {
                    colorWell.color = NSColor(hex: item.color!)
                }

            } else if textField.tag == 3 {
                item.filterClass = textField.stringValue

            } else if textField.tag == 4 {
                item.soundFile = textField.stringValue
            }
            
            self.reloadSelectedRow()
        }
    }
    
    func reloadSelectedRow() {
        self.reloadTargetRowColumn(self.tableView.selectedRow, column: 0)
    }
    
    func reloadTargetRowColumn(_ row:Int, column:Int) {
        let indexSet = IndexSet(integer: row)
        let columnSet = IndexSet(integer: column)
        self.tableView.reloadData(forRowIndexes: indexSet, columnIndexes: columnSet)
    }
    
    @IBAction func addRemoveAction(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            let highlight = Highlight()
            highlight.color = "#0000ff"
            _context!.highlights.add(highlight)
           
            let idx = IndexSet(integer: _context!.highlights.count() - 1)
            self.tableView.reloadData()
            self.tableView.scrollRowToVisible(idx.first!)
            self.tableView.selectRowIndexes(idx, byExtendingSelection: false)
        } else {
            
            if self.tableView.selectedRow < 0 || self.tableView.selectedRow >= _context!.highlights.count() {
                return
            }

            let selectedRow = self.tableView.selectedRow

            self.selectedItem = nil

            let item: Highlight = _context!.highlights.object(at: selectedRow) as! Highlight
            _context!.highlights.remove(item)

            self.tableView.reloadData()

            if _context!.highlights.count() > 0 {
                let idx = IndexSet(integer: 0)
                self.tableView.scrollRowToVisible(idx.first!)
                self.tableView.selectRowIndexes(idx, byExtendingSelection: false)
            }
        }
    }

    // MARK: NSTableViewDataSource

    open func numberOfRows(in tableView: NSTableView) -> Int {
        return _context!.highlights.count()
    }
    
    open func tableViewSelectionDidChange(_ notification:Notification) {

        stopSound()
        removeSound()

        var lastIdx = -1
        
        if let last = self.selectedItem {
            lastIdx = _context?.highlights.index(of: last) ?? -1
        }
        
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < _context!.highlights.count()) {
                self.selectedItem =
                    _context!.highlights.object(at: selectedRow) as? Highlight;
        }
        else {
            self.selectedItem = nil;
        }
        
        if lastIdx > -1 {
            self.reloadTargetRowColumn(lastIdx, column: 0)
        }
        
        self.reloadSelectedRow()
    }
    
    open func tableView(_ tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
        let cell = tableView.make(withIdentifier: "highlightCellView", owner: self) as? HighlightCellView
        
        if(row > -1 && row < _context!.highlights.count()) {
            
            if let hl = _context!.highlights.object(at: row) as? Highlight {
               
                cell?.pattern.stringValue = hl.pattern ?? ""
                cell?.filterClass.stringValue = hl.filterClass ?? ""

                if hl.color != nil && hl.color!.characters.count > 0 {
                    cell?.colorField.stringValue = hl.color!

                    let color = NSColor(hex: hl.color!)

                    cell?.colorField.textColor = color
                    cell?.pattern.textColor = color
                    cell?.filterClass.textColor = color

                } else {
                    cell?.colorField.stringValue = ""
                    cell?.colorField.textColor = nil
                    cell?.pattern.textColor = nil
                    cell?.filterClass.textColor = nil
                }

                if self.tableView.selectedRowIndexes.contains(row) {
                    cell?.selected = true
                } else {
                    cell?.selected = false
                }
                
                if hl.backgroundColor != nil && hl.backgroundColor!.characters.count > 0 {
                    cell?.backgroundColor = NSColor(hex: hl.backgroundColor!)
                } else {
                    cell?.backgroundColor = nil
                }
            }
        }

        return cell ?? NSView()
    }

    @IBAction func toggleSoundAction(_ sender: AnyObject) {
        guard self.selectedItem != nil else {
            stopSound()
            return
        }

        if _sound != nil && _sound!.isPlaying {
            stopSound()
        }
        else {
            if _sound != nil {
                playSound()
            } else {
                if let file = self.selectedItem?.soundFile {

                    var f = file

                    if !_fileSystem!.fileExists(f) {
                        f = _context!.pathProvider.soundsFolder().stringByAppendingPathComponent(file)
                        if !_fileSystem!.fileExists(f) { return }
                    }
                    
                    _sound = NSSound(contentsOfFile: f, byReference: false)
                    _sound?.delegate = self
                    playSound()
                }
            }
        }
    }

    open func sound(_ sound: NSSound, didFinishPlaying flag: Bool) {
        soundButton.image = NSImage(named: "Play")
    }

    func stopSound() {
        _sound?.stop()
        soundButton.image = NSImage(named: "Play")
    }

    func playSound() {
        if _sound != nil && _sound!.play() {
            soundButton.image = NSImage(named: "Stop")
        }
    }

    func removeSound() {
        _sound?.delegate = nil
        _sound = nil
    }

    @IBAction func browseForSoundAction(_ sender: AnyObject) {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose a sound file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["mp3", "wav"];

        if (dialog.runModal() == NSModalResponseOK) {
            if let result = dialog.url {

                if result.path != nil && result.path.hasPrefix(_context!.pathProvider.soundsFolder()) {
                    self.selectedItem?.soundFile = result.lastPathComponent

                } else {
                    self.selectedItem?.soundFile = result.path
                }

                stopSound()
                removeSound()
            }

        } else {
            return
        }
    }
}
