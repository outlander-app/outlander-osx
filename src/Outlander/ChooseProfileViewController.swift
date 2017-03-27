//
//  ChooseProfileViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 4/24/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class ProfileDataSource : NSObject, NSTableViewDataSource {
    
    fileprivate var context:GameContext
    
    var profiles:[String]
    
    init(_ context:GameContext) {
        self.context = context
        self.profiles = []
    }
    
    func loadProfiles() {
       self.profiles = getProfiles()
    }
    
    fileprivate func getProfiles() ->  [String] {
        var profiles:[String] = []
        
        let configFolder = self.context.pathProvider.configFolder()
        let profilesFolder = configFolder?.stringByAppendingPathComponent(self.context.settings.profilesFolder)
        
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: profilesFolder!)
        
        while let element = enumerator?.nextObject() as? String {
            if !element.characters.contains(".") {
                profiles.append(
                    element.trimmingCharacters(
                        in: CharacterSet.whitespacesAndNewlines)
                )
            }
        }
        
        return profiles
    }
}

class ChooseProfileViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    var okCommand:RACCommand?
    var cancelCommand:RACCommand?
    var gameContext:GameContext?
    var selectedProfile:String?
    var currentProfile:String?
    
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    fileprivate var profileDataSource:ProfileDataSource?
    
    override func awakeFromNib() {
        if let ok = self.okCommand {
            okButton.rac_command = ok
        }
        if let cancel = self.cancelCommand {
            cancelButton.rac_command = cancel
        }
        
        if let current = self.currentProfile {
        
            if let foundIndex = self.profileDataSource!.profiles.index(of: current) {
                
                if self.tableView != nil {
                
                    self.tableView.selectRowIndexes(IndexSet(integer: foundIndex), byExtendingSelection: false)
                }
            }
        }
    }

    func loadProfiles(_ current:String) {
        self.currentProfile = current
        if let ctx = self.gameContext {
            if let ds = self.profileDataSource {
                ds.loadProfiles()
            }
            else {
                self.profileDataSource = ProfileDataSource(ctx)
                self.profileDataSource?.loadProfiles()
            }
        }
    }
    
    // MARK: NSTableViewDataSource
    
    func tableViewSelectionDidChange(_ notification:Notification) {
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < self.profileDataSource?.profiles.count) {
                
                self.selectedProfile = self.profileDataSource?.profiles[selectedRow]
        }
        else {
            self.selectedProfile = nil;
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.profileDataSource?.profiles.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        if (row >= self.profileDataSource?.profiles.count){
            return "";
        }
        
        return self.profileDataSource?.profiles[row];
    }
}
