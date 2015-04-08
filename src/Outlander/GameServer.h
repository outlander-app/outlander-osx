//
//  GameServer.h
//  Outlander
//
//  Created by Joseph McBride on 1/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GCDAsyncSocket.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Shared.h"

@class GameContext;

@interface GameServer : NSObject {
    NSString *_host;
    UInt16 _port;
    GCDAsyncSocket *asyncSocket;
    NSString *_connection;
    RACSubject *_subject;
}

@property (atomic, strong) RACSubject *connected;

- (id)initWithContext:(GameContext *)context;

- (RACSignal*) connect:(NSString *) key toHost:(NSString *)host onPort:(UInt16)port;
- (void) sendCommand: (NSString *) command;
- (void) disconnect;
@end
