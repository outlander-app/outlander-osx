//
//  StubCommandRelay.h
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "CommandRelay.h"

@interface StubCommandRelay : NSObject <CommandRelay>

@property (nonatomic, strong) CommandContext *lastCommand;
@property (nonatomic, strong) TextTag *lastEcho;

@end
