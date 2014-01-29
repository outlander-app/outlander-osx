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
    if(self) {
        _text = text;
        _mono = mono;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TextTag: text='%@' mono='%hhd'", _text, _mono];
}

@end
