//
//  GameCommandProcessor.h
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "CommandProcessor.h"
#import "GameContext.h"
#import "VariableReplacer.h"

@interface GameCommandProcessor : NSObject <CommandProcessor>

-(id)initWith:(GameContext *)context and:(VariableReplacer *)replacer;

@end
