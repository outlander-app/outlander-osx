//
//  ChooseProfileViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 4/24/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

class ProfileDataSource : NSObject, NSTableViewDataSource {
    
    private var context:GameContext
    
    var profiles:[String]
    
    init(_ context:GameContext) {
        self.context = context
        self.profiles = []
    }
    
    func loadProfiles() {
       self.profiles = getProfiles()
    }
    
    private func getProfiles() ->  [String] {
        var profiles:[String] = []
        
        var configFolder = self.context.pathProvider.configFolder()
        var profilesFolder = configFolder.stringByAppendingPathComponent(self.context.settings.profilesFolder)
        
        let fileManager = NSFileManager.defaultManager()
        let enumerator = fileManager.enumeratorAtPath(profilesFolder)
        
        while let element = enumerator?.nextObject() as? String {
            if !contains(element, ".") {
                profiles.append(element)
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
    
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    private var profileDataSource:ProfileDataSource?
    
    override func awakeFromNib() {
        if let ok = self.okCommand {
            okButton.rac_command = ok
        }
        if let cancel = self.cancelCommand {
            cancelButton.rac_command = cancel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadProfiles(current:String) {
        if let ctx = self.gameContext {
            if let ds = self.profileDataSource {
                ds.loadProfiles()
                if let found = find(ds.profiles, current) {
                    //self.tableView.selectRowIndexes(NSIndexSet(index: found), byExtendingSelection: false)
                }
            }
            else {
                self.profileDataSource = ProfileDataSource(ctx)
                self.profileDataSource?.loadProfiles()
                if let found = find(self.profileDataSource!.profiles, current) {
                    
                    //self.tableView.selectRowIndexes(NSIndexSet(index: found), byExtendingSelection: false)
                }
            }
        }
    }
    
    // MARK: NSTableViewDataSource
    
    func tableViewSelectionDidChange(notification:NSNotification) {
        let selectedRow = self.tableView.selectedRow
        if(selectedRow > -1
            && selectedRow < self.profileDataSource?.profiles.count) {
                
                self.selectedProfile = self.profileDataSource?.profiles[selectedRow]
        }
        else {
            self.selectedProfile = nil;
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.profileDataSource?.profiles.count ?? 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        if (row >= self.profileDataSource?.profiles.count){
            return "";
        }
        
        return self.profileDataSource?.profiles[row];
    }
}
