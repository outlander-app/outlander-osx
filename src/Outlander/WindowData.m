//
//  WindowData.m
//  Outlander
//
//  Created by Joseph McBride on 5/1/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "WindowData.h"

@implementation WindowData

+ (id)windowWithName:(NSString *)name atLoc:(NSRect)loc {
    return [[self alloc] initWithName:name atLoc:loc];
}
- (id)initWithName:(NSString *)name atLoc:(NSRect)loc {
    self = [super init];
    if(!self) return nil;
    
    _name = name;
    _x = loc.origin.x;
    _y = loc.origin.y;
    _height = loc.size.height;
    _width = loc.size.width;
    
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
