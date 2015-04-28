//
//  GameCommandProcessor.h
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "CommandProcessor.h"
#import "VariableReplacer.h"

@class GameContext;
@protocol ISubscriber;

@interface GameCommandProcessor : NSObject <CommandProcessor, ISubscriber>

-(id)initWith:(GameContext *)context and:(VariableReplacer *)replacer;

@property (nonatomic, strong) RACSignal *processed;
@property (nonatomic, strong) RACSignal *echoed;

@end
