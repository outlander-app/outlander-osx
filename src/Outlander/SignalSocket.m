//
//  SignalSocket.m
//  Outlander
//
//  Created by Joseph McBride on 1/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SignalSocket.h"

@implementation SignalSocket

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    [self initialize];
    
    return self;
}

- (void) initialize {
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (RACSignal *) connect: (NSString *)host port:(UInt16)port {
	subject = [RACSubject subject];
    [asyncSocket connectToHost:host onPort:port error:nil];
    return subject;
}

- (RACSignal *) write: (NSString *)data {
    
    NSData *requestData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
    [asyncSocket readDataWithTimeout:-1 tag:0];
    
    return subject;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Connected");
    //[asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"socket:didReadData:withTag: %ld", tag);
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Response: %@", response);
    [subject sendNext:response];
    
    //[asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
    NSLog(@"socketDidDisconnect:withError:%@", err);
    [subject sendError:err];
    [subject sendCompleted];
}

@end
