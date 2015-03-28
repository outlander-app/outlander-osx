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

@interface MacrosViewController () {
    GameContext *_context;
}
@property (weak) IBOutlet NSTableView *tableView;
//@property (weak) IBOutlet DDHotKeyTextField *macroTextField;
@property (weak) IBOutlet NSTextField *actionTextField;
@property (weak) IBOutlet NSSegmentedControl *buttonGroup;
@end

@implementation MacrosViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (!self) return nil;
    
    return self;
}
- (IBAction)addRemove:(id)sender {
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    NSInteger selectedSeg = [control selectedSegment];
    
    switch (selectedSeg) {
        case 0: {
            NSLog(@"Add");
            Macro *macro = [[Macro alloc] init];
            [_context.macros addObject:macro];
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:_context.macros.count -1];
            [_tableView selectRowIndexes:indexSet byExtendingSelection:NO];
        
            [_tableView scrollRowToVisible:indexSet.firstIndex];
            
            [_tableView reloadData];
            }
            break;
            
        case 1:
            NSLog(@"Remove: %ld", (long)_tableView.selectedRow);
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

- (void)awakeFromNib {
    [_actionTextField.rac_textSignal subscribeNext:^(NSString *val) {
        if(_selectedMacro) {
            _selectedMacro.action = val;
            [_tableView reloadData];
        }
    }];
    
    if(_context.macros.count > 0) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
        [_tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
}

- (void)setContext:(GameContext *)context {
    _context = context;
    [_context.macros.changed subscribeNext:^(id x) {
        [_tableView reloadData];
    }];
    [_tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _context.macros.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    Macro *macro = [_context.macros objectAtIndex:row];
    
    if([tableColumn.identifier isEqualToString:@"macro"]) {
        return macro.keys;
    } else {
        return macro.action;
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if(_tableView.selectedRow >-1 && _tableView.selectedRow < _context.macros.count) {
        self.selectedMacro = [_context.macros objectAtIndex:_tableView.selectedRow];
    }
    else {
        self.selectedMacro = nil;
    }
}

@end
