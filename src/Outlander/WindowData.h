//
//  WindowData.h
//  Outlander
//
//  Created by Joseph McBride on 5/1/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface WindowData : MTLModel <MTLJSONSerializing>

+ (id)windowWithName:(NSString *)name atLoc:(NSRect)loc andTimestamp:(BOOL)timestamp;
- (id)initWithName:(NSString *)name atLoc:(NSRect)loc andTimestamp:(BOOL)timestamp;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) double width;
@property (nonatomic, copy) NSString *closedTarget;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL timestamp;
@property (nonatomic, assign) BOOL showBorder;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) double fontSize;
@property (nonatomic, copy) NSString *monoFontName;
@property (nonatomic, assign) double monoFontSize;

@end
