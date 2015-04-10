//
//  WindowData.m
//  Outlander
//
//  Created by Joseph McBride on 5/1/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "WindowData.h"

@implementation WindowData

+ (id)windowWithName:(NSString *)name atLoc:(NSRect)loc andTimestamp:(BOOL)timestamp {
    return [[self alloc] initWithName:name atLoc:loc andTimestamp:timestamp];
}
- (id)initWithName:(NSString *)name atLoc:(NSRect)loc andTimestamp:(BOOL)timestamp {
    self = [super init];
    if(!self) return nil;
    
    _name = name;
    _x = loc.origin.x;
    _y = loc.origin.y;
    _height = loc.size.height;
    _width = loc.size.width;
    _timestamp = timestamp;
    _showBorder = YES;
    _fontName = @"Helvetica";
    _fontSize = 14;
    _monoFontName = @"Menlo";
    _monoFontSize = 13;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%f,%f)(%fx%f)", _x, _y, _height, _width];
}

@end
