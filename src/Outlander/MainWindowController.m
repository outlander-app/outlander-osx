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

@interface MainWindowController ()
    @property (nonatomic, strong) NSViewController *currentViewController;
@end

@implementation MainWindowController

- (id)init {
	self = [super initWithWindowNibName:NSStringFromClass([self class]) owner:self];
	if(self == nil) return nil;
	
	return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
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
