//
//  SendCommandHandler.h
//  Outlander
//
//  Created by Joseph McBride on 6/15/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "CommandHandler.h"

@interface SendCommandHandler : NSObject <CommandHandler>

- (instancetype)initWith:(GameContext *)context;

@end
