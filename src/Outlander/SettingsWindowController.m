//
//  SettingsWindowController.m
//  Outlander
//
//  Created by Joseph McBride on 6/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SettingsWindowController.h"
#import "MacrosViewController.h"

@interface SettingsWindowController () {
    GameContext *_context;
}
    @property (nonatomic, strong) NSViewController *currentViewController;
@end

@implementation SettingsWindowController

- (id)init {
	self = [super initWithWindowNibName:NSStringFromClass([self class]) owner:self];
    if (!self) return nil;
    
    return self;
}

- (void)setContext:(GameContext *)context {
    _context = context;
}

- (void)save {
}

- (void)windowWillClose:(NSNotification *)notification {
    id<SettingsView> current = (id<SettingsView>)self.currentViewController;
    if(current) {
        [current save];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OL:registerMacros"
                                                        object:nil
                                                      userInfo:nil];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OL:unregisterMacros"
                                                        object:nil
                                                      userInfo:nil];
    
    MacrosViewController *vc = [[MacrosViewController alloc] init];
    [vc setContext:_context];
    [self setCurrentViewController:vc];
}

- (void)setCurrentViewController:(NSViewController *)vc {
	if(_currentViewController == vc) return;
	
	_currentViewController = vc;
	self.window.contentView = _currentViewController.view;
}

@end
