//
//  AppDelegate.m
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate() {
    NSMutableArray *windows;
}
@end

@implementation AppDelegate

- (MainWindowController *)activeWindowController {
    NSWindow *win = [[NSApplication sharedApplication] keyWindow];
    return win.windowController;
}

- (IBAction)newAction:(id)sender {
    
	MainWindowController *ctrl = [[MainWindowController alloc] init];
    [windows addObject:ctrl];
    [ctrl.window makeKeyAndOrderFront:nil];
}

- (IBAction)connectAction:(id)sender {
    [[self activeWindowController] showLogin];
}

- (IBAction)connectWithProfile:(id)sender {
    [[self activeWindowController] showProfiles];
}

- (IBAction)saveProfileAction:(id)sender {
    [self sendCommand:@"saveSettings"];
}

- (IBAction)preferencesAction:(id)sender {
    [self sendCommand:@"preferences"];
}

- (IBAction)autoMapperAction:(id)sender {
    [self sendCommand:@"showAutoMapper"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    windows = [[NSMutableArray alloc] init];
	MainWindowController *ctrl = [[MainWindowController alloc] init];
    [windows addObject:ctrl];
    
    [ctrl.window makeKeyAndOrderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
}

- (void)sendCommand:(NSString *)command {
    [[self activeWindowController] command:command];
}

@end
