//
//  OEPauseCondition.h
//  Outlander
//
//  Created by Joseph McBride on 6/13/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ExecuteBlock.h"

@interface OLPauseCondition : NSObject

- (BOOL)isPaused;
- (BOOL)isTimedOut;
- (void)cancel;
- (void)signal;
- (ExecuteBlock *)wait;
- (ExecuteBlock *)waitUntilTimeInterval:(NSTimeInterval)interval;

@end
