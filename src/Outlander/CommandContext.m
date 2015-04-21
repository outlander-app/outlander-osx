//
//  CommandContext.m
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "CommandContext.h"

@implementation CommandContext

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scriptLine = -1;
        self.scriptColumn = -1;
    }
    return self;
}

@end
