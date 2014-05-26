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
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"

#define START_WIDTH 900
#define START_HEIGHT 615

@interface MainWindowController ()
    @property (nonatomic, strong) LoginViewController *loginViewController;
    @property (nonatomic, strong) IBOutlet NSPanel *sheet;
    @property (nonatomic, strong) NSViewController *currentViewController;
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
    
	return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
//    [[self.window windowController] setShouldCascadeWindows:NO];
//    [self.window setFrameAutosaveName:[self.window representedFilename]];
//
    TestViewController *vc = [[TestViewController alloc]init];
    
    
    [self setCurrentViewController:vc];
    
    @weakify(self);
    @weakify(vc);
    
    [[vc.gameContext.globalVars.changed throttle:0.5]subscribeNext:^(id x) {
        
        @strongify(self);
        @strongify(vc);
        NSString *game = [vc.gameContext.globalVars cacheObjectForKey:@"game"];
        NSString *character = [vc.gameContext.globalVars cacheObjectForKey:@"charactername"];
        [self.window setTitle:[NSString stringWithFormat:@"%@: %@", game, character]];
    }];
    
    _loginViewController.context = vc.gameContext;
    
    [self.window makeFirstResponder:vc._CommandTextField];
    [vc._CommandTextField becomeFirstResponder];
}

- (void)awakeFromNib {
    
    int maxX = NSMaxX([[NSScreen mainScreen] frame]);
    int maxY = NSMaxY([[NSScreen mainScreen] frame]);
    
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
}

- (void)setCurrentViewController:(NSViewController *)vc {
	if(_currentViewController == vc) return;
	
	_currentViewController = vc;
	self.window.contentView = _currentViewController.view;
}

- (void)command:(NSString *)command {
    if([_currentViewController conformsToProtocol:@protocol(Commands)]) {
        id<Commands> vc = (id<Commands>)_currentViewController;
        [vc command:command];
    }
}

- (void)showLogin {
    [self showSheet:_loginViewController.view];
}

- (void)dismissLogin {
    [self endSheet];
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


@end
