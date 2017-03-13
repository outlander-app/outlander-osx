//
//  MyView.h
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TextViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "KeyHandler.h"

@interface MyView : NSView {
}
@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *borderColor;
@property (nonatomic, assign) BOOL draggable;
@property (nonatomic, assign) NSPoint mouseLoc;
@property (nonatomic, strong) NSView *movingTile;
@property (nonatomic, assign) BOOL hit;
@property (nonatomic, assign) float kX;
@property (nonatomic, assign) float kY;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) BOOL showBorder;
@property (nonatomic, strong) RACSignal *keyup;

- (void)setKeyHandler:(id<KeyHandler>)handler;

- (void)addViewFromTextView:(TextViewController *)controller;
- (TextViewController*)createTextController:(NSString *)key atLoc:(NSRect)rect;
- (TextViewController*)addView:(NSColor *)color atLoc:(NSRect)rect withKey:(NSString *)key;
- (TextViewController*)addViewOld:(NSColor *)color atLoc:(NSRect)rect withKey:(NSString *)key;

- (BOOL)hasView:(NSString *)key;
- (void)bringToFront:(NSString *)key;
@end
