//
//  MainWindowController.m
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MainWindowController.h"
#import "TestViewController.h"
#import "NSView+Categories.h"

#define START_WIDTH 900
#define START_HEIGHT 600

@interface MainWindowController ()
    @property (nonatomic, strong) NSViewController *currentViewController;
@end

@implementation MainWindowController

- (id)init {
	self = [super initWithWindowNibName:NSStringFromClass([self class]) owner:self];
	if(self == nil) return nil;
    
    int maxX = NSMaxX([[NSScreen mainScreen] frame]);
    int maxY = NSMaxY([[NSScreen mainScreen] frame]);
    
    [self.window setFrame:NSMakeRect((maxX / 2.0) - (START_WIDTH / 2.0),
                                     (maxY / 2.0) - (START_HEIGHT / 2.0),
                                     START_WIDTH,
                                     START_HEIGHT)
                  display:YES
                  animate:NO];
	return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[self.window windowController] setShouldCascadeWindows:NO];
    [self.window setFrameAutosaveName:[self.window representedFilename]];
//
    TestViewController *vc = [[TestViewController alloc]init];
    
    [self setCurrentViewController:vc];
    
//    [self.window makeFirstResponder:vc._CommandTextField];
//    [vc._CommandTextField becomeFirstResponder];
}

- (void)setCurrentViewController:(NSViewController *)vc {
	if(_currentViewController == vc) return;
	
	_currentViewController = vc;
	self.window.contentView = _currentViewController.view;
}

@end
