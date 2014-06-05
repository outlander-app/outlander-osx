//
//  PauseToken.m
//  Outlander
//
//  Created by Joseph McBride on 6/5/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "PauseToken.h"

@interface PauseToken () {
    NSNumber *_val;
}
@end

@implementation PauseToken

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