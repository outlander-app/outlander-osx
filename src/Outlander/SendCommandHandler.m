//
//  SendCommandHandler.m
//  Outlander
//
//  Created by Joseph McBride on 6/15/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SendCommandHandler.h"
#import "CommandContext.h"
#import "NSString+Categories.h"
#import "Outlander-Swift.h"

@interface SendCommandHandler () {
    SendQueue *_sendQueue;
}
@end

@implementation SendCommandHandler

- (instancetype)initWith:(GameContext *)context {
    self = [super init];
    if (!self) return nil;

    _sendQueue = [SendQueue newInstance:context];

    return self;
}

- (BOOL)canHandle:(NSString *)command {
    return [[command lowercaseString] hasPrefix:@"#send"];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    NSString *msg = [command substringFromIndex:5];
    [_sendQueue enqueue:msg];
}

@end
