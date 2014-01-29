//
//  GameServer.h
//  Outlander
//
//  Created by Joseph McBride on 1/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "RACReplaySubject.h"
#import "RACSignal.h"
#import "Shared.h"

@interface GameServer : NSObject {
    GCDAsyncSocket *asyncSocket;
    NSString *_connection;
    RACReplaySubject *_subject;
}
- (RACSignal*) connect:(NSString *) key toHost:(NSString *)host onPort:(UInt16)port;
- (void) sendCommand: (NSString *) command;
@end
