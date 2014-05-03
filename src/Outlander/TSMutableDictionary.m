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
    dispatch_barrier_async(_queue, ^{
        [_cache setObject: obj forKey: key];
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

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    [_cache enumerateKeysAndObjectsUsingBlock:block];
}

@end
