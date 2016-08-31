//
//  SignalSocket.h
//  Outlander
//
//  Created by Joseph McBride on 1/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface SignalSocket : NSObject <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *asyncSocket;
	RACSubject *subject;
}

- (RACSignal *) connect: (NSString *)host port:(UInt16)port;
- (RACSignal *) write: (NSString *)data;

@end
