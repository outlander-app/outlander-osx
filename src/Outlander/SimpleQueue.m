//
//  SimpleQueue.m
//  Outlander
//
//  Created by Joseph McBride on 6/15/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SimpleQueue.h"

@interface SimpleQueue () {
    NSMutableArray *_cache;
}
@end

@implementation SimpleQueue

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _cache = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)queue:(id)item {
    [_cache addObject:item];
}

- (id)dequeue {
    id item = [_cache firstObject];
    
    if(_cache.count > 0) {
        [_cache removeObjectAtIndex:0];
    }
    
    return item;
}

- (BOOL)hasObjectType:(Class)aClass {
    __block BOOL hasType = NO;
    
    [_cache enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:aClass]) {
            hasType = YES;
            *stop = YES;
        }
    }];
    
    return hasType;
}

- (void)clear {
    [_cache removeAllObjects];
}

- (NSUInteger)count {
    return _cache.count;
}

@end
