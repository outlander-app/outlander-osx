//
//  LRToken.m
//  Outlander
//
//  Created by Joseph McBride on 6/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "LRToken.h"

@implementation LRToken

-(instancetype)initWith:(id<Token>)right and:(id<Token>)left {
    self = [super init];
    if(!self) return nil;
    
    _right = right;
    _left = left;
    
    return self;
}

-(id)eval {
    return nil;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ Left=%@ Right=%@", [super description], [_left eval], [_right eval]];
}

@end
