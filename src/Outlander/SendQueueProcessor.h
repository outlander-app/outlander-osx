//
//  SendActor.h
//  Outlander
//
//  Created by Joseph McBride on 6/15/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Actor.h"
#import "GameContext.h"
#import "OLPauseCondition.h"
#import "SimpleQueue.h"

@interface SendQueueProcessor : NSObject

- (void)configure:(GameContext *)context with:(doneBlock)block;
- (void)process;

@end
