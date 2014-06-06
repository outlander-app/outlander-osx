//
//  TokenList.m
//  Outlander
//
//  Created by Joseph McBride on 6/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TokenList.h"
#import "ReactiveCocoa.h"

@implementation TokenList

- (instancetype)init {
    self = [super init];
    if(!self) return nil;
    
    _tokens = [[NSMutableArray alloc] init];
    
    return self;
}

-(id)eval {
    return [[_tokens.rac_sequence map:^id(id<Token> value) {
        return [value eval];
    }].array componentsJoinedByString:@" "];
}

@end
