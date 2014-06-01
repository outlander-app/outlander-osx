//
//  Match.m
//  Outlander
//
//  Created by Joseph McBride on 5/31/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Match.h"

@implementation Match

+(instancetype)match:(NSString *)label with:(NSString *)text and:(BOOL)isRegex {
    return [[self alloc] init:label with:text and:isRegex];
}

-(instancetype)init:(NSString *)label with:(NSString *)text and:(BOOL)isRegex {
    self = [super init];
    if(!self) return nil;
    
    _label = label;
    _text = text;
    _isRegex = isRegex;
    
    return self;
}
@end
