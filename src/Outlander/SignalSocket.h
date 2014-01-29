//
//  SignalSocket.h
//  Outlander
//
//  Created by Joseph McBride on 1/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "RACMulticastConnection.h"
#import "RACReplaySubject.h"

@interface SignalSocket : NSObject {
    GCDAsyncSocket *asyncSocket;
	RACReplaySubject *subject;
}

- (RACSignal *) connect: (NSString *)host port:(UInt16)port;
- (RACSignal *) write: (NSString *)data;

@end
