//
//  SendCommandHandler.m
//  Outlander
//
//  Created by Joseph McBride on 6/15/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SendCommandHandler.h"
#import "CommandRelay.h"
#import "GameCommandRelay.h"
#import "NSString+Categories.h"

@interface SendCommandHandler () {
    id<CommandRelay> _commandRelay;
}
@end

@implementation SendCommandHandler

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
   
    _commandRelay = [[GameCommandRelay alloc] init];
    
    return self;
}

- (BOOL)canHandle:(NSString *)command {
    return [command hasPrefix:@"#send"];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    NSString *msg = [command substringFromIndex:5];
    
    CommandContext *ctx = [[CommandContext alloc] init];
    ctx.command = [msg trimWhitespaceAndNewline];
    ctx.tag = [TextTag tagFor:[NSString stringWithFormat:@"%@\n", ctx.command] mono:YES];
    ctx.tag.color = @"#ACFF2F";
    
    [_commandRelay sendCommand:ctx];
}

@end
