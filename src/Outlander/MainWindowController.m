//
//  MainWindowController.m
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MainWindowController.h"
#import "TestViewController.h"
#import "ProgressBarViewController.h"
#import "NSView+Categories.h"
#import "LoginViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>
#import "SettingsWindowController.h"
#import "ApplicationUpdateViewController.h"
#import <Squirrel/Squirrel.h>

#define START_WIDTH 900
#define START_HEIGHT 615

@interface MainWindowController ()
    @property (nonatomic, strong) LoginViewController *loginViewController;
    @property (nonatomic, strong) SettingsWindowController *settingsWindowController;
    @property (nonatomic, strong) IBOutlet NSPanel *sheet;
    @property (nonatomic, strong) NSViewController *currentViewController;
    @property (nonatomic, strong) ApplicationUpdateViewController *appUpdateController;
    @property (nonatomic, strong) SQRLUpdater *updater;
@end

@implementation MainWindowController

- (id)init {
	self = [super initWithWindowNibName:NSStringFromClass([self class]) owner:self];
	if(self == nil) return nil;
    
    _loginViewController = [[LoginViewController alloc] init];
    
    _loginViewController.cancelCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        [self endSheet];
        return [RACSignal empty];
    }];
    
    _loginViewController.connectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        [self endSheet];
        [self command:@"connect"];
        return [RACSignal empty];
    }];
    
    _settingsWindowController = [[SettingsWindowController alloc] init];
    
    _appUpdateController = [[ApplicationUpdateViewController alloc] init];
    _appUpdateController.okCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self endSheet];
        return [RACSignal empty];
    }];
    _appUpdateController.relaunchCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self endSheet];
        [[self.updater relaunchToInstallUpdate] subscribeError:^(NSError *error) {
            NSLog(@"Error preparing update: %@", error);
        }];
        
        return [RACSignal empty];
    }];
    
	return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
//    [[self.window windowController] setShouldCascadeWindows:NO];
//    [self.window setFrameAutosaveName:[self.window representedFilename]];
//
    TestViewController *vc = [[TestViewController alloc]init];
   
    [_settingsWindowController setContext:vc.gameContext];
    
    [self setCurrentViewController:vc];
    
    @weakify(self);
    @weakify(vc);
    
    [[vc.gameContext.globalVars.changed throttle:0.5]subscribeNext:^(id x) {
        
        @strongify(self);
        @strongify(vc);
        NSString *game = [vc.gameContext.globalVars cacheObjectForKey:@"game"];
        NSString *character = [vc.gameContext.globalVars cacheObjectForKey:@"charactername"];
        
        NSDictionary *dict = [[NSBundle bundleForClass:self.class] infoDictionary];
        NSString *version = dict[@"CFBundleShortVersionString"];
        
        [self.window setTitle:[NSString stringWithFormat:@"%@: %@ - Outlander %@ Alpha", game, character, version]];
    }];
    
    _loginViewController.context = vc.gameContext;
    
    [self.window makeFirstResponder:vc._CommandTextField];
    [vc._CommandTextField becomeFirstResponder];
    
    [self checkForUpdates];
}

- (void)awakeFromNib {
    
    int maxX = NSMaxX([[NSScreen mainScreen] visibleFrame]);
    int maxY = NSMaxY([[NSScreen mainScreen] visibleFrame]);
    
//    [self.window setFrame:NSMakeRect((maxX / 2.0) - (START_WIDTH / 2.0),
//                                     (maxY / 2.0) - (START_HEIGHT / 2.0),
//                                     maxX,
//                                     maxY)
//                  display:YES
//                  animate:NO];
    
    maxX = maxX < START_WIDTH ? START_WIDTH : maxX;
    
    [self.window setFrame:NSMakeRect(0,
                                     0,
                                     maxX,
                                     maxY)
                  display:YES
                  animate:NO];
    
    self.window.delegate = self;
}

- (void)setCurrentViewController:(NSViewController *)vc {
	if(_currentViewController == vc) return;
	
	_currentViewController = vc;
	self.window.contentView = _currentViewController.view;
}

- (void)command:(NSString *)command {
    
    if([command isEqualToString:@"preferences"]){
        
        [_settingsWindowController.window setParentWindow:self.window];
        [_settingsWindowController.window makeKeyAndOrderFront:self];
        
    }else if([_currentViewController conformsToProtocol:@protocol(Commands)]) {
        id<Commands> vc = (id<Commands>)_currentViewController;
        [vc command:command];
    }
}

- (void)showLogin {
    [self showSheet:_loginViewController.view];
}

- (void)showAppUpdate {
    [self showSheet:_appUpdateController.view];
}

- (void)showSheet:(NSView *)view {
    self.sheet.contentView = view;
    [self.sheet setFrame:view.frame display:YES animate:NO];
    
    [NSApp beginSheet:self.sheet
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (void)endSheet {
    [NSApp endSheet:self.sheet];
    [self.sheet orderOut:self];
    self.sheet.contentView = nil;
}

- (BOOL)windowShouldClose:(id)sender {
    [self command:@"saveProfile"];
    [self command:@"saveConfig"];
    return YES;
}

- (void)windowWillClose:(NSNotification *)notification {
}

- (void)checkForUpdates {
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    
    components.scheme = @"http";
//    components.host = @"localhost";
//    components.port = @(5000);
    components.host = @"outlanderapp.com";
    components.path = @"/version";
    
    NSDictionary *dict = [[NSBundle bundleForClass:self.class] infoDictionary];
    NSString *version = dict[@"CFBundleShortVersionString"];
    
    components.query = [[NSString stringWithFormat:@"version=v%@", version] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    NSLog(@"%@", components.URL);
    
    self.updater = [[SQRLUpdater alloc] initWithUpdateRequest:[NSURLRequest requestWithURL:components.URL]];
    
    [self.updater.updates subscribeNext:^(SQRLDownloadedUpdate *downloadedUpdate) {
        NSLog(@"An update is ready to install: %@", downloadedUpdate);
        [self showAppUpdate];
    }];
    
    // Check for updates immediately on launch, then every 4 hours.
    [self.updater.checkForUpdatesCommand execute:RACUnit.defaultUnit];
    [self.updater startAutomaticChecksWithInterval:60 * 60 * 4];
}

@end
