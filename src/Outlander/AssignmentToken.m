//
//  AssignmentToken.m
//  Outlander
//
//  Created by Joseph McBride on 6/5/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AssignmentToken.h"

@implementation AssignmentToken

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

@end
