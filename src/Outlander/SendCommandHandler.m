//
//  SendCommandHandler.m
//  Outlander
//
//  Created by Joseph McBride on 6/15/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SendCommandHandler.h"
#import "CommandContext.h"
#import "CommandRelay.h"
#import "GameCommandRelay.h"
#import "NSString+Categories.h"
#import "SimpleQueue.h"
#import "SendQueueProcessor.h"

@interface SendCommandHandler () {
    id<CommandRelay> _commandRelay;
    SimpleQueue *_queue;
    SendQueueProcessor *_sendProcessor;
}
@end

@implementation SendCommandHandler

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
  
    _queue = [[SimpleQueue alloc] init];
    _commandRelay = [[GameCommandRelay alloc] init];
    return self;
}

- (BOOL)canHandle:(NSString *)command {
    return [command hasPrefix:@"#send"];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    NSString *msg = [command substringFromIndex:5];
    [_queue queue:msg];
    
    _sendProcessor = [[SendQueueProcessor alloc] init];
    
    [_sendProcessor configure:context with:^{
        [self sendAll];
    }];
    
    [_sendProcessor process];
}

- (void)sendAll {
    
    id msg = nil;
    
    while ((msg = [_queue dequeue])) {
        
        NSArray *commands = [msg componentsSeparatedByString:@";"];
        
        [commands enumerateObjectsUsingBlock:^(NSString *command, NSUInteger idx, BOOL *stop) {
            CommandContext *ctx = [[CommandContext alloc] init];
            ctx.command = [command trimWhitespaceAndNewline];
            ctx.tag = [TextTag tagFor:[NSString stringWithFormat:@"%@\n", ctx.command] mono:YES];
            ctx.tag.color = @"#ACFF2F";
            [_commandRelay sendCommand:ctx];
        }];
    }
}

@end
