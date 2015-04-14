//
//  TextTag.m
//  Outlander
//
//  Created by Joseph McBride on 1/25/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TextTag.h"

@implementation TextTag

+ tagFor:(NSString*)text mono:(BOOL)mono {
    return [[self alloc] initWith:text mono:mono];
}

- initWith:(NSString*)text mono:(BOOL)mono {
    self = [super init];
    if(!self) return nil;
    
    _text = text;
    _mono = mono;
    _bold = NO;
    _scriptLine = -1;
    _scriptColumn = -1;
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TextTag: text='%@' mono='%hhd' color='%@' href='%@' command='%@'", _text, _mono, _color, _href, _command];
}

@end
