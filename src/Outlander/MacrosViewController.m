//
//  MacrosViewController.m
//  Outlander
//
//  Created by Joseph McBride on 6/21/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MacrosViewController.h"
#import "Macro.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OLShortcutView.h"
#import <MASShortcut/MASShortcut.h>
#import "MASShortcut+Categories.h"
#import "AppSettingsLoader.h"

@interface MacrosViewController () {
    GameContext *_context;
    AppSettingsLoader *_appsettingsLoader;
}
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *actionTextField;
@property (weak) IBOutlet NSSegmentedControl *buttonGroup;
@property (weak) IBOutlet OLShortcutView *macroShortcutView;
@end

@implementation MacrosViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (!self) return nil;
    
    return self;
}

- (void)awakeFromNib {
    
    _macroShortcutView.shortcutValueChange = ^(OLShortcutView *sender){
        if(_selectedMacro && sender.shortcutValue) {
            
            NSString *keyCode = sender.shortcutValue.keyCode == NSUIntegerMax
                ? @""
                : [NSString stringWithFormat:@"%lu", sender.shortcutValue.keyCode];
            
            _selectedMacro.keys =
                [NSString stringWithFormat:@"%@%@",
                       sender.shortcutValue.modifierFlagsString,
                       keyCode];
        }
        else if (_selectedMacro) {
            _selectedMacro.keys = @"";
        }
        
        [_tableView reloadData];
    };
    
    [_actionTextField.rac_textSignal subscribeNext:^(NSString *val) {
        if(_selectedMacro) {
            _selectedMacro.action = val;
            [_tableView reloadData];
        }
    }];
}

-(void)viewDidAppear {
    if(_context.macros.count > 0) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
        [_tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
}

- (void)setContext:(GameContext *)context {
    _context = context;
    _appsettingsLoader = [[AppSettingsLoader alloc] initWithContext:_context];
    
    [_context.macros.changed subscribeNext:^(id x) {
        [_tableView reloadData];
    }];
    [_tableView reloadData];
}

- (void)save {
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [_tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    [_tableView scrollRowToVisible:indexSet.firstIndex];
    
    // filter out empty macros
    __block NSMutableArray *remove = [[NSMutableArray alloc] init];
    [_context.macros enumerateObjectsUsingBlock:^(Macro *macro, NSUInteger idx, BOOL *stop) {
        if(macro.keys.length == 0){
            [remove addObject:macro];
        }
    }];
    
    [remove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_context.macros removeObject:obj];
    }];
    
    [_tableView reloadData];
    
    [_appsettingsLoader saveMacros];
}

- (IBAction)addRemove:(id)sender {
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    NSInteger selectedSeg = [control selectedSegment];
    
    switch (selectedSeg) {
        case 0: {
            Macro *macro = [[Macro alloc] init];
            [_context.macros addObject:macro];
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:_context.macros.count -1];
            [_tableView selectRowIndexes:indexSet byExtendingSelection:NO];
            
            [_tableView scrollRowToVisible:indexSet.firstIndex];
            
            [_tableView reloadData];
            break;
        }
            
        case 1: {
            if(_tableView.selectedRow < 0 || _tableView.selectedRow >= _context.macros.count) {
                break;
            }
            
            self.selectedMacro = nil;
            
            Macro *macro = [_context.macros objectAtIndex:_tableView.selectedRow];
            [_context.macros removeObject:macro];
            
            [_tableView reloadData];
            break;
        }
    }
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _context.macros.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if (row >= _context.macros.count){
        return @"";
    }
    
    Macro *macro = [_context.macros objectAtIndex:row];
    
    if([tableColumn.identifier isEqualToString:@"macro"]) {
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:macro.keyCode modifierFlags:macro.modifiers];
        return shortcut.olDescription;
    } else {
        return macro.action;
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if(_tableView.selectedRow >-1 && _tableView.selectedRow < _context.macros.count) {
        self.selectedMacro = [_context.macros objectAtIndex:_tableView.selectedRow];
        _macroShortcutView.recording = NO;
        _macroShortcutView.shortcutValue = [MASShortcut shortcutWithKeyCode:self.selectedMacro.keyCode
                                                              modifierFlags:self.selectedMacro.modifiers];
    }
    else {
        self.selectedMacro = nil;
    }
}

@end
