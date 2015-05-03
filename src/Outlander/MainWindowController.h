//
//  MainWindowController.h
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Commands.h"

@protocol ISubscriber;

@interface MainWindowController : NSWindowController <Commands, NSWindowDelegate, ISubscriber>

- (id)init;
- (void)command:(NSString *)command;
- (void)showLogin;
- (void)showProfiles;
- (void)showAppUpdate;
- (void)showSheet:(NSView *)view withFrame:(NSRect)frame;
- (void)endSheet;
@end
