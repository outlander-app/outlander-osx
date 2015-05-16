//
//  OLMutableArray.h
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface OLMutableArray : NSObject

@property (nonatomic, strong) RACSignal *changed;
@property (nonatomic, strong) RACSignal *removed;

- (NSInteger)count;
- (void)addObject:(id)item;
- (void)removeAll;
- (NSInteger)indexOfObject:(id)item;
- (void)removeObject:(id)item;
- (id)objectAtIndex:(NSInteger)index;
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void)signalChange:(id)item;

@end
