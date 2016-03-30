//
//  TextViewController.h
//  Outlander
//
//  Created by Joseph McBride on 1/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TextTag.h"
#import "NSColor+Categories.h"
#import "MyNSTextView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@class GameContext;

@interface TextViewController : NSViewController <NSTextStorageDelegate>

@property (nonatomic, strong) GameContext *gameContext;
@property (nonatomic, strong) RACSignal *keyup;
@property (nonatomic, strong) RACSignal *command;
@property (nonatomic, copy) NSString *key;
@property (unsafe_unretained) IBOutlet MyNSTextView *TextView;

@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) double fontSize;
@property (nonatomic, copy) NSString *monoFontName;
@property (nonatomic, assign) double monoFontSize;

@property (nonatomic, copy) NSString *windowTitle;
@property (nonatomic, copy) NSString *closedTarget;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) BOOL lastShowBorder;
@property (nonatomic, assign) NSRect lastLocation;

- (BOOL)showBorder;
- (void)setShowBorder:(BOOL)show;
- (void)setDisplayTimestamp:(BOOL)timestamp;
- (NSString *)text;
- (void)setWithTags:(NSArray *)tags;
- (void)beginEdit;
- (void)endEdit;
- (void)clear;
- (BOOL)endsWith:(NSString*)value;
- (void)append:(TextTag*)text;
- (BOOL)displayTimestamp;

- (NSRect)location;

- (void)removeView;
@end
