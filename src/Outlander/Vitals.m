//
//  Vitals.m
//  Outlander
//
//  Created by Joseph McBride on 1/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Vitals.h"

@implementation Vitals

-(id)initWith:(NSString*)name value:(UInt16)value {
    self = [super init];
    if(self == nil) return nil;
    
    _name = name;
    _value = value;
    
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ name=%@ value=%hu", [super description], _name, _value];
}

@end
