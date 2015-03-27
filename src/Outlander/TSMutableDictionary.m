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
    _changed = [RACSubject subject];
    
    return self;
}

- (id)cacheObjectForKey: (id)key {
    __block id obj;
    @synchronized(self) {
        obj = [_cache objectForKey: key];
    }
    return obj;
}

- (void)setCacheObject: (id)obj forKey: (id)key {
    NSLog(@"%@::%@", key, obj);
    if(key == nil) {
        return;
    }
    if (obj == nil) {
        obj = @"";
    }
    
    @synchronized(self) {
        [_cache setObject: obj forKey: key];
    }
    
    id<RACSubscriber> sub = (id<RACSubscriber>)_changed;
    [sub sendNext:@{key: obj}];
}

- (BOOL)cacheDoesContain: (id)key {
    __block BOOL hasKey;
    @synchronized(self) {
        hasKey = [_cache objectForKey:key] != nil;
    }
    return hasKey;
}

- (NSArray *)allItems {
    __block NSArray *items = nil;
    @synchronized(self) {
        items = [_cache allValues];
    }
    return items;
}

- (NSArray *)allKeys {
    __block NSArray *keys = nil;
    
    @synchronized(self) {
        keys = [[_cache allKeys] sortedArrayUsingSelector: @selector(compare:)];
    }
    
    return keys;
}

- (NSUInteger)count {
    __block NSUInteger count;
    
    @synchronized(self) {
       count = [_cache count];
    }
    
    return count;
}

- (void)removeObjectForKey:(id)key {
    @synchronized(self) {
        [_cache removeObjectForKey:key];
    }
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    @synchronized(self) {
        [_cache enumerateKeysAndObjectsUsingBlock:block];
    }
}

- (void)removeAllObjects {
    @synchronized(self) {
        [_cache removeAllObjects];
    }
}

@end
