//
//  AppDelegate.m
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AppDelegate.h"
#import "AppSettingsLoader.h"
#import "MainWindowController.h"
#import "UpdateWindowController.h"
#import "NSString+Categories.h"
#import "Outlander-Swift.h"
#import <Squirrel/Squirrel.h>

@interface AppDelegate() {
    NSMutableArray *windows;
    SQRLUpdater *updater;
    GameContext *gameContext;
    AppSettingsLoader *appSettingsLoader;
    UpdateWindowController *updateWindow;
}
@end

@implementation AppDelegate

- (MainWindowController *)activeWindowController {
    NSWindow *win = [[NSApplication sharedApplication] keyWindow];
    MainWindowController *ctrl = win.windowController;

    if(ctrl == nil && windows.count > 0) {
        return windows[0];
    }

    return ctrl;
}

- (IBAction)newAction:(id)sender {
    MainWindowController *ctrl = [[MainWindowController alloc] initWithSettings: gameContext.settings];
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

- (IBAction)checkforUpdatesAction:(id)sender {

//    [updateWindow.window makeKeyAndOrderFront:nil];

    [self checkForUpdates];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    windows = [[NSMutableArray alloc] init];

    gameContext = [GameContext newInstance];
    appSettingsLoader = [[AppSettingsLoader alloc] initWithContext:gameContext];
    [appSettingsLoader loadConfig];

    MainWindowController *ctrl = [[MainWindowController alloc] initWithSettings: gameContext.settings];
    [windows addObject:ctrl];
    
    [ctrl.window makeKeyAndOrderFront:nil];

    updateWindow = [[UpdateWindowController alloc] init];

    [self setupUpdater];

    if(gameContext.settings.checkForApplicationUpdates) {
        [updater.checkForUpdatesCommand execute:RACUnit.defaultUnit];
    } else {
        [self logUpdateInfo:@"disabled"];
    }
}

- (void)setupUpdater {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"http";
    components.host = @"outlanderapp.com";
//    components.host = @"localhost";
//    components.port = @(3000);
    components.path = @"/api/updates";
    
    NSDictionary *dict = [[NSBundle bundleForClass:self.class] infoDictionary];
    NSString *version = dict[@"CFBundleShortVersionString"];

    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];

    NSString *osVersionString = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)osVersion.majorVersion, (long)osVersion.minorVersion, (long)osVersion.patchVersion];

    components.query = [[NSString stringWithFormat:@"version=v%@&os=%@", version, osVersionString] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    [self logUpdateInfo:[NSString stringWithFormat:@"Update URL %@", components.URL] withPreset:@"" echo:NO];

    updater = [[SQRLUpdater alloc] initWithUpdateRequest:[NSURLRequest requestWithURL:components.URL]];
    [updater addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptionNew) context:nil];

    [updater.updates subscribeNext:^(SQRLDownloadedUpdate *downloadedUpdate) {
        [self logUpdateInfo:[NSString stringWithFormat:@"Update ready to install: %@", downloadedUpdate.update.releaseName]];

        [updateWindow setUpdater:updater with:downloadedUpdate.update];
        [updateWindow.window makeKeyAndOrderFront:nil];
    }];

    [updater.checkForUpdatesCommand.errors subscribeNext:^(NSError *error) {
        [self logUpdateInfo:error.localizedDescription withPreset:@"scripterror" echo:YES];
    }];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
}

- (void)sendCommand:(NSString *)command {
    [[self activeWindowController] command:command];
}

- (void)checkForUpdates {
    [updater.checkForUpdatesCommand execute:RACUnit.defaultUnit];
//    [self.updater startAutomaticChecksWithInterval:60 * 60 * 4];
//    [self.updater.checkForUpdatesCommand execute:RACUnit.defaultUnit];
//    [updater startAutomaticChecksWithInterval:10];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(SQRLUpdater *)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if(object.state == SQRLUpdaterStateIdle) {
        [self logUpdateInfo: @"Idle" withPreset:@"appupdates" echo:NO];
    }
    else if(object.state == SQRLUpdaterStateCheckingForUpdate) {
        [self logUpdateInfo: @"Checking for Application Update"];
    }
    else if(object.state == SQRLUpdaterStateDownloadingUpdate) {
        [self logUpdateInfo: @"Downloading Application Update"];
    }
    else if(object.state == SQRLUpdaterStateAwaitingRelaunch) {
        [self logUpdateInfo: @"Awaiting Relaunch for Application Update"];
    }
}

- (void)logUpdateInfo:(NSString *)info {
    [self logUpdateInfo:info withPreset:@"appupdates" echo:YES];
}

- (void)logUpdateInfo:(NSString *)info withPreset:(NSString *)preset echo:(BOOL)echo {

    if(echo) {
        [[self activeWindowController] echo:[NSString stringWithFormat:@"[Application Update]: %@", info]
                                       withPreset:preset];
    }

    NSString * data = [NSString stringWithFormat:@"%@ %@\n",[@"%@" stringFromDateFormat: @"yyyy-MM-dd hh:mm:ss"], info];

    NSLog(@"%@", data);
    
    NSString *logsFolder = [gameContext.pathProvider logsFolder];

    NSString *fileName = [NSString stringWithFormat:@"Updater-%@.txt",
                          [@"%@" stringFromDateFormat:@"yyyy-MM-dd"]];

    NSString *filePath = [logsFolder stringByAppendingPathComponent:fileName];
    [data appendToFile:filePath encoding:NSUTF8StringEncoding];
}

@end
