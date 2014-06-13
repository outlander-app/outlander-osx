//
//  DebugLevelToken.m
//  Outlander
//
//  Created by Joseph McBride on 6/12/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "DebugLevelToken.h"

@interface DebugLevelToken () {
    NSNumber *_val;
}
@end

@implementation DebugLevelToken

- (instancetype)initWith:(NSNumber *)val {
    self = [super init];
    if(!self) return nil;
    
    _val = val;
    
    return self;
}

- (id)eval {
    return _val;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", [super description], _val];
}

@end