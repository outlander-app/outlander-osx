//
//  TSMutableDictionary.m
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TSMutableDictionary.h"

@implementation TSMutableDictionary

-(id)initWithName:(NSString *)queueName {
    self = [super init];
    if(self == nil) return nil;

    _cache = [[NSMutableDictionary alloc] init];
    _queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
    _changed = [RACSubject subject];
    
    return self;
}

- (id)cacheObjectForKey: (id)key {
    __block id obj;
    dispatch_sync(_queue, ^{
        obj = [_cache objectForKey: key];
    });
    return obj;
}

- (void)setCacheObject: (id)obj forKey: (id)key {
    NSLog(@"%@::%@", key, obj);
    if (obj == nil) {
        obj = @"";
    }
    if(key == nil) {
        NSLog(@"WAT");
    }
    dispatch_barrier_async(_queue, ^{
        [_cache setObject: obj forKey: key];
        
        id<RACSubscriber> sub = (id<RACSubscriber>)_changed;
        [sub sendNext:@{key: obj}];
    });
}

- (BOOL)cacheDoesContain: (id)key {
    __block BOOL hasKey;
    dispatch_sync(_queue, ^{
        hasKey = [_cache objectForKey:key] != nil;
    });
    return hasKey;
}

- (NSArray *)allItems {
    __block NSArray *items = nil;
    dispatch_sync(_queue, ^{
        items = [_cache allValues];
    });
    return items;
}

- (NSArray *)allKeys {
    __block NSArray *keys = nil;
    
    dispatch_sync(_queue, ^{
        keys = [[_cache allKeys] sortedArrayUsingSelector: @selector(compare:)];
    });
    
    return keys;
}

- (NSUInteger)count {
    __block NSUInteger count;
    dispatch_sync(_queue, ^{
       count = [_cache count];
    });
    return count;
}

- (void)removeObjectForKey:(id)key {
    dispatch_barrier_async(_queue, ^{
        [_cache removeObjectForKey:key];
    });
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    dispatch_sync(_queue, ^{
        [_cache enumerateKeysAndObjectsUsingBlock:block];
    });
}

- (void)removeAllObjects {
    dispatch_barrier_async(_queue, ^{
        [_cache removeAllObjects];
    });
}

@end
