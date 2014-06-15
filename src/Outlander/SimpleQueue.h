//
//  SimpleQueue.h
//  Outlander
//
//  Created by Joseph McBride on 6/15/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface SimpleQueue : NSObject

- (void)queue:(id)item;
- (id)dequeue;
- (BOOL)hasObjectType:(Class)aClass;
- (void)clear;
- (NSUInteger)count;

@end
