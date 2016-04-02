//
//  MacroHandler.m
//  Outlander
//
//  Created by Joseph McBride on 6/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MacroHandler.h"
#import "TextTag.h"
#import <MASShortcut/MASShortcut.h>
#import <MASShortcut/MASShortcutMonitor.h>
#import "Outlander-Swift.h"

@interface MacroHandler () {
    GameContext *_context;
    id<CommandRelay> _commandRelay;
    BOOL _isApplicationActive;
}
@end

@implementation MacroHandler

- (instancetype)initWith:(GameContext *)context and:(id<CommandRelay>)commandRelay {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    _commandRelay = commandRelay;
    
    [_context.macros.removed subscribeNext:^(Macro *macro) {
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:macro.keyCode modifierFlags:0];
        [[MASShortcutMonitor sharedMonitor] unregisterShortcut:shortcut];
    }];
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)registerMacros {
    [_context.macros enumerateObjectsUsingBlock:^(Macro *macro, NSUInteger idx, BOOL *stop) {
        [self registerMacro:macro];
    }];
}

-(void)registerMacro:(Macro *)macro {
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:macro.keyCode modifierFlags:macro.modifiers];
    [[MASShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
        if(macro != nil){
            CommandContext *ctx = [[CommandContext alloc] init];
            ctx.command = macro.action;
            [_commandRelay sendCommand:ctx];
        }
    }];
}

-(void)unRegisterMacros {
    [[MASShortcutMonitor sharedMonitor] unregisterAllShortcuts];
}

@end
