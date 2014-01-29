//
//  CharacterViewModel.m
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "CharacterViewModel.h"

@implementation CharacterViewModel

- (id)init {
    self = [super init];
    if(self == nil) return nil;
    
    _spell = @"None";
    _lefthand = @"L: Empty";
    _righthand = @"R: Empty";
    _roundtime = 0;
    
    return self;
}

@end
