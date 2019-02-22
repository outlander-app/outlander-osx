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
#import "AppSettingsLoader.h"
#import "TextTag.h"
#import "NSString+Categories.h"
#import "MacroHandler.h"
#import "GameCommandRelay.h"
#import "Outlander-Swift.h"

@interface MainWindowController ()
    @property (nonatomic, strong) LoginViewController *loginViewController;
    @property (nonatomic, strong) SettingsWindowController *settingsWindowController;
    @property (nonatomic, strong) AutoMapperWindowController *autoMapperWindowController;
    @property (nonatomic, strong) IBOutlet NSPanel *sheet;
    @property (nonatomic, strong) NSViewController *currentViewController;
    @property (nonatomic, strong) ChooseProfileViewController *chooseProfileViewController;
    @property (nonatomic, strong) GameContext *gameContext;
@end

@implementation MainWindowController {
    AppSettingsLoader *_appSettingsLoader;
    MacroHandler *_macroHandler;
}

- (id)initWithSettings:(AppSettings *)settings {
	self = [super initWithWindowNibName:NSStringFromClass([self class]) owner:self];
	if(self == nil) return nil;
    
    _gameContext = [GameContext newInstance];

    [_gameContext.settings copyFrom:settings];

    _appSettingsLoader = [[AppSettingsLoader alloc] initWithContext:_gameContext];
    _macroHandler = [[MacroHandler alloc] initWith:_gameContext and:[[GameCommandRelay alloc] initWith:_gameContext.events]];
    
    _loginViewController = [[LoginViewController alloc] init];
    
    _loginViewController.cancelCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {

        _gameContext.settings.password = @"";
        
        [self endSheet];
        return [RACSignal empty];
    }];
    
    _loginViewController.connectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        [self endSheet];
        [self command:@"connect"];
        return [RACSignal empty];
    }];
    
    _settingsWindowController = [[SettingsWindowController alloc] init];
    
    _autoMapperWindowController = [[AutoMapperWindowController alloc] initWithWindowNibName:@"AutoMapperWindowController"];
    [_autoMapperWindowController setContext:_gameContext];

    _chooseProfileViewController = [[ChooseProfileViewController alloc]
                                    initWithNibName:@"ChooseProfileViewController"
                                    bundle:nil];
   
    _chooseProfileViewController.gameContext = _gameContext;
    _chooseProfileViewController.okCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self endSheet];

        [_gameContext.classSettings clear];
        
        [_appSettingsLoader loadProfile:_chooseProfileViewController.selectedProfile];

        [[self currentVC] reloadTheme];
        [[self currentVC] removeAllWindows];
        [[self currentVC] loadWindows];
        [self setWindowFrame];

        [self echoText:[NSString stringWithFormat:@"Loaded profile: %@\n", _gameContext.pathProvider.profileFolder] withMono:YES];

        [self showLogin];
        
        return [RACSignal empty];
    }];
    
    _chooseProfileViewController.cancelCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self endSheet];
        return [RACSignal empty];
    }];
    
    [_gameContext.events subscribe:self token:@"disconnected"];
    [_gameContext.events subscribe:self token:@"OL:map:reload"];
    [_gameContext.events subscribe:self token:@"variable:changed"];

	return self;
}

- (void)echo:(NSString *)text withPreset: (NSString *)preset {
    [[self.gameContext events] echoText:text mono:YES preset:preset];
}

- (void) windowDidBecomeKey: (NSNotification*) note {
    [self registerMacros];
}

- (void) windowDidResignKey: (NSNotification*) note {
    [self unRegisterMacros];
}

- (void)handle:(NSString * __nonnull)token data:(NSDictionary * __nonnull)data {
    if ([token isEqualToString:@"disconnected"]) {
        [self saveSettings];
    }

    if([token isEqualToString:@"OL:map:reload"]) {
        [_autoMapperWindowController loadMaps];
    }

    if([token isEqualToString:@"variable:changed"]) {
        [data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSLog(@"%@::%@", key, obj);
        }];

        if(!([data objectForKey:@"game"] || [data objectForKey:@"charactername"])) {
            return;
        }

        NSString *charInfo = @"";
        NSString *game = [_gameContext.globalVars get:@"game"];
        NSString *character = [_gameContext.globalVars get:@"charactername"];
        
        if (game == nil) {
            game = @"";
        }
        
        if (character == nil) {
           character = @"";
        }
        
        if (game.length > 0 && character.length > 0) {
            charInfo = [NSString stringWithFormat:@"%@: %@ - ", game, character];
        }
        
        NSDictionary *dict = [[NSBundle bundleForClass:self.class] infoDictionary];
        NSString *version = dict[@"CFBundleShortVersionString"];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.window setTitle:[NSString stringWithFormat:@"%@Outlander %@ Alpha", charInfo, version]];
        });
    }
}

- (TestViewController *)currentVC {
    return (TestViewController *)_currentViewController;
}

- (void)windowDidMove:(NSNotification *)notification {
    [self updateWindowLayout];
}

- (void)windowDidResize:(NSNotification *)notification {
    [self updateWindowLayout];
}

- (void)updateWindowLayout {
    Layout *layout = _gameContext.layout;
    layout.primaryWindow.x = self.window.frame.origin.x;
    layout.primaryWindow.y = self.window.frame.origin.y;
    layout.primaryWindow.height = self.window.frame.size.height;
    layout.primaryWindow.width = self.window.frame.size.width;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [_settingsWindowController setContext:_gameContext];
    
//    GameViewController *gv = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
//    [self setCurrentViewController:gv];
    
    TestViewController *vc = [[TestViewController alloc] initWithContext:_gameContext];
    [self setCurrentViewController:vc];
    
    NSDictionary *dict = [[NSBundle bundleForClass:self.class] infoDictionary];
    NSString *version = dict[@"CFBundleShortVersionString"];
    
    [self.window setTitle:[NSString stringWithFormat:@"Outlander %@ Alpha", version]];
    
    _loginViewController.context = _gameContext;

    [self printSettings];

    [self.window makeFirstResponder:vc._CommandTextField];
}

-(void)echoText:(NSString *)text withMono:(BOOL)mono {
    TestViewController *vc = [self currentVC];

    [vc append:[TextTag tagFor:text
                          mono:mono]
            to:@"main"];
}

- (void)printSettings {
    [self echoText:[NSString stringWithFormat:@"Config: %@\n",
                    _gameContext.pathProvider.configFolder]
          withMono:YES];
    [self echoText:[NSString stringWithFormat:@"Profile: %@\n",
                    _gameContext.pathProvider.profileFolder]
          withMono:YES];
    [self echoText:[NSString stringWithFormat:@"Maps: %@\n",
                    _gameContext.pathProvider.mapsFolder]
          withMono:YES];
    [self echoText:[NSString stringWithFormat:@"Scripts: %@\n",
                    _gameContext.pathProvider.scriptsFolder]
          withMono:YES];
    [self echoText:[NSString stringWithFormat:@"Logs: %@\n\n",
                    _gameContext.pathProvider.logsFolder]
          withMono:YES];
}

- (void)awakeFromNib {

    [_appSettingsLoader load];
    [_autoMapperWindowController loadMaps];

    [self setWindowFrame];
    
    self.window.delegate = self;
}

- (void)setWindowFrame {
    [self.window setFrame:NSMakeRect(_gameContext.layout.primaryWindow.x,
                                     _gameContext.layout.primaryWindow.y,
                                     _gameContext.layout.primaryWindow.width,
                                     _gameContext.layout.primaryWindow.height)
                  display:YES
                  animate:NO];
}

- (void)setCurrentViewController:(NSViewController *)vc {
	if(_currentViewController == vc) return;
	
	_currentViewController = vc;
	self.window.contentView = _currentViewController.view;
}

- (void) saveSettings {
    TestViewController *vc = [self currentVC];
    _gameContext.layout.windows = [vc getWindows];

    [_appSettingsLoader saveConfig];
    [_appSettingsLoader saveProfile];
    [_appSettingsLoader saveVariables];
    [_appSettingsLoader saveHighlights];
    [_appSettingsLoader saveAliases];
    [_appSettingsLoader saveMacros];
    [_appSettingsLoader saveTriggers];
    [_appSettingsLoader saveSubs];
    [_appSettingsLoader saveGags];
    [_appSettingsLoader savePresets];
    [_appSettingsLoader saveVitals];
    [_appSettingsLoader saveClasses];
    
    [self echoText:[@"[%@] settings saved\n" stringFromDateFormat:@"HH:mm"] withMono:YES];
}

- (void)command:(NSString *)command {

    if([command isEqualToString:@"saveSettings"]) {
        
        [self saveSettings];
        
    } else if([command isEqualToString:@"preferences"]){
        
        [_settingsWindowController showWindow:self];
    } else if([command isEqualToString:@"showAutoMapper"]){
        
        [_autoMapperWindowController showWindow:self];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [_autoMapperWindowController setSelectedZone];
        });

    } else if([command isEqualToString:@"layout:LoadDefault"]) {

        [self loadLayout:@"default.cfg"];

    } else if([command isEqualToString:@"layout:SaveDefault"]) {

        [self saveLayout:@"default.cfg"];

    } else if([command isEqualToString:@"layout:Load"]) {

        NSString *file = [self pickOpenFile];
        if (file.length != 0) {
            [self loadLayout:file];
        }

    } else if([command isEqualToString:@"layout:SaveAs"]) {

        NSString *file = [self pickSaveFile];
        if (file.length != 0) {
            [self saveLayout:file];
        }

    } else if([_currentViewController conformsToProtocol:@protocol(Commands)]) {
        id<Commands> vc = (id<Commands>)_currentViewController;
        [vc command:command];
    }
}

- (void)loadLayout:(NSString *)file {
    _gameContext.settings.layout = file;
    [_appSettingsLoader saveProfile];
    [_appSettingsLoader loadLayout:_gameContext.settings.layout];

    TestViewController *vc = [self currentVC];
    [vc reloadTheme];
    [vc removeAllWindows];
    [vc loadWindows];

    [self setWindowFrame];

    NSString *text = [NSString stringWithFormat:@"%@ loaded layout %@\n", [@"[%@]" stringFromDateFormat:@"HH:mm"], file];
    [self echoText:text withMono:YES];
}

- (void)saveLayout:(NSString *)file {
    TestViewController *vc = [self currentVC];

    _gameContext.settings.layout = file;
    _gameContext.layout.windows = [vc getWindows];

    [_appSettingsLoader saveProfile];
    [_appSettingsLoader saveLayout:_gameContext.settings.layout];

    NSString *text = [NSString stringWithFormat:@"%@ saved layout as %@\n", [@"[%@]" stringFromDateFormat:@"HH:mm"], file];
    [self echoText:text withMono:YES];
}

- (NSString *)pickOpenFile {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setDirectoryURL: [NSURL URLWithString:_gameContext.pathProvider.layoutFolder]];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];

    NSInteger clicked = [panel runModal];

    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            return [url lastPathComponent];
        }
    }

    return @"";
}

- (NSString *)pickSaveFile {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setDirectoryURL: [NSURL URLWithString:_gameContext.pathProvider.layoutFolder]];
    [panel setNameFieldStringValue:_gameContext.settings.layout];

    NSInteger clicked = [panel runModal];

    if (clicked == NSFileHandlingPanelOKButton) {
        return [[panel URL] lastPathComponent];
    }

    return @"";
}

- (void)showLogin {
    NSRect viewRect = NSMakeRect(0, 0, 308, 120);
    [self showSheet:_loginViewController.view withFrame:viewRect];
}

- (void)showProfiles {
    NSRect viewRect = NSMakeRect(0, 0, 192, 237);
    [_chooseProfileViewController loadProfiles:_gameContext.settings.profile];
    [self showSheet:_chooseProfileViewController.view withFrame:viewRect];
}

- (void)showSheet:(NSView *)view withFrame:(NSRect)frame {
    self.sheet.contentView = view;
    
    [self.sheet setFrame:frame display:YES animate:NO];
    
    [self.window beginSheet:self.sheet completionHandler:nil];
}

- (void)endSheet {
    [NSApp endSheet:self.sheet];
    [self.sheet orderOut:self];
    self.sheet.contentView = nil;
}

- (BOOL)windowShouldClose:(id)sender {
    [self command:@"saveSettings"];
    return YES;
}

- (void)windowWillClose:(NSNotification *)notification {
}

-(void)registerMacros {
    [_macroHandler registerMacros];
}

-(void)unRegisterMacros {
    [_macroHandler unRegisterMacros];
}

@end
