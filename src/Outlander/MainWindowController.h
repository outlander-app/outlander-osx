//
//  MainWindowController.h
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Commands.h"
#import "AppSettings.h"

@protocol ISubscriber;

@interface MainWindowController : NSWindowController <Commands, NSWindowDelegate, ISubscriber>

- (id)initWithSettings:(AppSettings *)settings;
- (void)command:(NSString *)command;
- (void)showLogin;
- (void)showProfiles;
- (void)showSheet:(NSView *)view withFrame:(NSRect)frame;
- (void)endSheet;
- (void)echo:(NSString *)text withPreset: (NSString *)preset;
@end
