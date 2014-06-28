//
//  TSMutableDictionary.h
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//
// https://mikeash.com/pyblog/friday-qa-2011-10-14-whats-new-in-gcd.html

#import <ReactiveCocoa/EXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface TSMutableDictionary : NSObject {

    NSMutableDictionary *_cache;
    dispatch_queue_t _queue;
}

@property (nonatomic, strong) RACSignal *changed;

- (id)initWithName:(NSString *)queueName;
- (id)cacheObjectForKey: (id)key;
- (void)setCacheObject: (id)obj forKey: (id)key;
- (BOOL)cacheDoesContain: (id)key;
- (NSArray *)allKeys;
- (NSArray *)allItems;
- (NSUInteger)count;
- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;
@end
