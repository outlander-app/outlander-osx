//
//  OLMutableArray.m
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "OLMutableArray.h"

@interface OLMutableArray () {
    NSMutableArray *_cache;
}
@end

@implementation OLMutableArray

- (instancetype)init {
    self = [super init];
    if(!self) return nil;
    
    _cache = [[NSMutableArray alloc] init];
    _changed = [RACReplaySubject subject];
    
    return self;
}

- (NSInteger)count {
    return _cache.count;
}

- (void)addObject:(id)item {
    [_cache addObject:item];
    [self signalChange:item];
}

- (id)objectAtIndex:(NSInteger)index {
    return _cache[index];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    [_cache enumerateObjectsUsingBlock:block];
}

- (void)signalChange:(id)item {
    id<RACSubscriber> sub = (id<RACSubscriber>)_changed;
    [sub sendNext:item];
}

@end
