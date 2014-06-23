//
//  MacrosViewController.m
//  Outlander
//
//  Created by Joseph McBride on 6/21/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MacrosViewController.h"
#import "Macro.h"

@interface MacrosViewController () {
    GameContext *_context;
}
@property (weak) IBOutlet NSTableView *tableView;
@end

@implementation MacrosViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (!self) return nil;
    
    return self;
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
    NSLog(@"selection changed");
    _selectedMacro = [_context.macros objectAtIndex:_tableView.selectedRow];
}

@end
