//
//  SimpleStack.m
//  Outlander
//
//  Created by Joseph McBride on 6/11/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SimpleStack.h"

@interface SimpleStack () {
    NSMutableArray *_cache;
}
@end

@implementation SimpleStack

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _cache = [[NSMutableArray alloc] init];
    
    return self;
}

- (id)pop {
    id item = [_cache lastObject];
    [_cache removeLastObject];
    return item;
}

- (void)push:(id)item {
    [_cache addObject:item];
}

- (NSUInteger)count {
    return _cache.count;
}

@end
