//
//  Actor.h
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//
//  http://albertodebortoli.github.io/blog/2014/05/20/asynchronous-message-passing-with-actors-in-objective-c/

@interface Actor : NSThread

@property (nonatomic, copy, readonly) NSString *uuid;

- (void)suspend;
- (void)resume;
- (BOOL)isPaused;
- (void)process;

@end
