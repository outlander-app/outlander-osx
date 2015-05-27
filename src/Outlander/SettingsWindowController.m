//
//  SettingsWindowController.m
//  Outlander
//
//  Created by Joseph McBride on 6/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SettingsWindowController.h"
#import "MacrosViewController.h"
#import "Outlander-Swift.h"

typedef NS_ENUM(NSUInteger, SettingsOption) {
    SettingsOptionMacros = 0,
    SettingsOptionAliases = 1,
    SettingsOptionVariables = 2,
    SettingsOptionHighlights = 3,
    SettingsOptionWindows = 4,
};

@interface SettingsWindowController () {
    GameContext *_context;
}
    @property (nonatomic, strong) NSViewController *currentViewController;
    @property (weak) IBOutlet NSToolbar *toolbar;
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

- (void)awakeFromNib {
    [self setSection:SettingsOptionHighlights];
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
}

- (IBAction)selectSection:(NSToolbarItem *)sender {
    id<SettingsView> current = (id<SettingsView>)_currentViewController;
    [current save];
    
    [self setSection:(SettingsOption)sender.tag];
}

- (void)setSection:(SettingsOption)option {
    
    NSViewController *vc = nil;
    NSString *identifier = @"";
    
    switch (option) {
        default:
        case SettingsOptionMacros:
            identifier = @"macro";
            vc = [[MacrosViewController alloc] init];
            break;
            
        case SettingsOptionAliases:
            identifier = @"alias";
            vc = [[AliasesViewController alloc] initWithNibName:@"AliasesViewController" bundle:[NSBundle mainBundle]];
            break;
            
        case SettingsOptionVariables:
            identifier = @"variable";
            vc = [[VariablesViewController alloc] initWithNibName:@"VariablesViewController" bundle:[NSBundle mainBundle]];
            break;
            
        case SettingsOptionHighlights:
            identifier = @"highlight";
            vc = [[HighlightsViewController alloc] initWithNibName:@"HighlightsViewController" bundle:[NSBundle mainBundle]];
            break;
            
        case SettingsOptionWindows:
            identifier = @"windows";
            vc = [[WindowsViewController alloc] initWithNibName:@"WindowsViewController" bundle:[NSBundle mainBundle]];
            //vc = [[ScriptToolbarViewController alloc] initWithNibName:@"ScriptToolbarViewController" bundle:[NSBundle mainBundle]];
            break;
    }
    
    id<SettingsView> settings = (id<SettingsView>)vc;
    [settings setContext:_context];
    
    [self.toolbar setSelectedItemIdentifier:identifier];
    [self setCurrentViewController:vc];
}

- (void)setCurrentViewController:(NSViewController *)vc {
	if(_currentViewController == vc) return;
	
	_currentViewController = vc;
	self.window.contentView = _currentViewController.view;
}

@end
