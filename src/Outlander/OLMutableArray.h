//
//  OLMutableArray.h
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ReactiveCocoa.h"

@interface OLMutableArray : NSObject

@property (nonatomic, strong) RACSignal *changed;

- (NSInteger)count;
- (void)addObject:(id)item;
- (id)objectAtIndex:(NSInteger)index;
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void)signalChange:(id)item;

@end
