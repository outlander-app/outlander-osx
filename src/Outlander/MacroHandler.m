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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:NSApplicationDidBecomeActiveNotification
                                               object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidResignActive:)
                                                 name:NSApplicationDidResignActiveNotification
                                               object:nil ];
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSApplicationDidResignActiveNotification
                                                  object:nil];
}

-(void)registerMacros {
    [_context.macros enumerateObjectsUsingBlock:^(Macro *macro, NSUInteger idx, BOOL *stop) {
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:[macro.keys integerValue] modifierFlags:0];
        [[MASShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
            if(_isApplicationActive && macro != nil){
                CommandContext *ctx = [[CommandContext alloc] init];
                ctx.command = macro.action;
                [_commandRelay sendCommand:ctx];
            }
        }];
    }];
}

-(void)unRegisterMacros {
    [[MASShortcutMonitor sharedMonitor] unregisterAllShortcuts];
}

-(void) applicationDidBecomeActive: (NSNotification*) note{
    _isApplicationActive = YES;
    [self registerMacros];
}

-(void) applicationDidResignActive: (NSNotification*) note{
    _isApplicationActive = NO;
    [self unRegisterMacros];
}

@end
