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
    _highlights = [[OLMutableArray alloc] init];
    _aliases = [[OLMutableArray alloc] init];
    _macros = [[OLMutableArray alloc] init];
    _globalVars = [[TSMutableDictionary alloc] initWithName:@"com.outlander.gobalvars"];
    
    [_globalVars setCacheObject:@">" forKey:@"prompt"];
    [_globalVars setCacheObject:@"Empty" forKey:@"lefthand"];
    [_globalVars setCacheObject:@"Empty" forKey:@"righthand"];
    [_globalVars setCacheObject:@"None" forKey:@"preparedspell"];
    [_globalVars setCacheObject:@"0" forKey:@"tdp"];
    
    return self;
}

@end
