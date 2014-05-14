//
//  GameContext.m
//  Outlander
//
//  Created by Joseph McBride on 5/7/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameContext.h"

@implementation GameContext

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    _settings = [[AppSettings alloc] init];
    _pathProvider = [[AppPathProvider alloc] initWithSettings:_settings];
    
    return self;
}

@end
