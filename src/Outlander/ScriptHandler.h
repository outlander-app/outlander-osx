//
//  ScriptHandler.h
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "CommandHandler.h"
#import "EventRelay.h"

@interface ScriptHandler : NSObject <CommandHandler>

- (instancetype)initWith:(id<EventRelay>)relay;

@end
