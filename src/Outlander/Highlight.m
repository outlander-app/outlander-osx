//
//  Highlight.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Highlight.h"

@implementation Highlight

-(id)init {
    self = [super init];
    if(!self) return nil;

    _color = @"";
    _backgroundColor = @"";
    _pattern = @"";
    _filterClass = @"";
    
    return self;
}
@end
