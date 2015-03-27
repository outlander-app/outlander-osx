//
//  AppDelegate.m
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate()
    @property (nonatomic, strong) MainWindowController *mainWindowController;
@end

@implementation AppDelegate

- (IBAction)newAction:(id)sender {
    //[self.mainWindowController showAppUpdate];
}

- (IBAction)connectAction:(id)sender {
    [self.mainWindowController showLogin];
}

- (IBAction)saveProfileAction:(id)sender {
    [self sendCommand:@"saveSettings"];
}

- (IBAction)preferencesAction:(id)sender {
    [self sendCommand:@"preferences"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.mainWindowController = [[MainWindowController alloc] init];
	[self.mainWindowController.window makeKeyAndOrderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
}

- (void)sendCommand:(NSString *)command {
    [_mainWindowController command:command];
}

@end
