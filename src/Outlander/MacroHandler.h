//
//  MacroHandler.h
//  Outlander
//
//  Created by Joseph McBride on 6/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "CommandRelay.h"
#import "GameContext.h"
#import "Macro.h"

@interface MacroHandler : NSObject

- (instancetype)initWith:(GameContext *)context and:(id<CommandRelay>)commandRelay;

@end
