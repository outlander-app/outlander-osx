//
//  MyView.h
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextViewController.h"

@interface MyView : NSView {
}
@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, assign) BOOL draggable;
@property (nonatomic, assign) NSPoint mouseLoc;
@property (nonatomic, strong) NSView *movingTile;
@property (nonatomic, assign) BOOL hit;
@property (nonatomic, assign) float kX;
@property (nonatomic, assign) float kY;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) BOOL showBorder;
@property (nonatomic, strong) NSMutableArray *viewsList;

- (TextViewController*)addView:(NSColor *)color atLoc:(NSRect)rect withKey:(NSString *)key;
@end
