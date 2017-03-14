//
//  GameServer.m
//  Outlander
//
//  Created by Joseph McBride on 1/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameServer.h"
#import "NSString+Categories.h"
#import "Outlander-Swift.h"

@interface GameServer () {
    GameContext *_gameContext;
    BOOL _matchedToken;
}
@end

@implementation GameServer

- (id)initWithContext:(GameContext *)context {
    self = [super init];
    if (self == nil) return nil;
    
    _gameContext = context;
    
    _subject = [RACSubject subject];
    _connected = [RACSubject subject];
    _matchedToken = NO;
    
    return self;
}

- (RACSignal*) connect:(NSString *) key toHost:(NSString *)host onPort:(UInt16)port {
    
    _host = host;
    _port = port;
    
    _connection = [NSString stringWithFormat:@"%@\r\n/FE:STORMFRONT /VERSION:%@ /P:%@ /XML\r\n", key, @"1.0.1.26", @"OSX"];
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [asyncSocket connectToHost:host onPort:port error:nil];
    
    return _subject;
}

- (void) sendCommand: (NSString *) command {
    if(![asyncSocket isConnected]) return;
    
    NSData *data = [[NSString stringWithFormat:@"%@\r\n", command] dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:data
               withTimeout:-1
                       tag:0];
}

- (void) disconnect {
    [_connected sendCompleted];
    [_subject sendCompleted];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Connected");
    
    NSString *msg = [NSString stringWithFormat:@"connected to %@ on port %hu", _host, _port];
    [_connected sendNext:msg];
    
    NSData *data = [_connection dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:data
               withTimeout:-1
                       tag:0];
    [asyncSocket readDataToData:[self getData] withTimeout:-1.0 tag:0];
}

- (NSData *)getData {
    return [GCDAsyncSocket CRLFData];
//    return [NSData dataWithBytes:"\x0D\x0A\x0D\x0A" length:4];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
//    NSLog(@"socket:didReadData:withTag: %ld", tag);
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", response);
    
    if(!_matchedToken && [self matchesToken:response]) {
        _matchedToken = YES;
        NSMutableString *replaced = [NSMutableString stringWithString:response];
        [self replace:replaced withPattern:@"GSw\\d+"];
        NSData *data = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:data withTimeout:-1 tag:-1];
        [_subject sendNext:[NSString stringWithString:replaced]];
    }
    else {
        [_subject sendNext:response];
    }
    
    [asyncSocket readDataToData:[self getData] withTimeout:-1.0 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
    NSLog(@"socketDidDisconnect:withError:%@", err);
    [_subject sendCompleted];
}

- (BOOL) matchesToken: (NSString *) data {
    return [self valueMatches:data pattern:@"GSw\\d+"];
}

- (BOOL) valueMatches:(NSString *)data pattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger matches = [regex numberOfMatchesInString:data
                                                    options:0
                                                      range:NSMakeRange(0, [data length])];
    
    return matches > 0;
}

-(void) replace: (NSMutableString *)data withPattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    [regex replaceMatchesInString:data options:0 range:NSMakeRange(0, [data length]) withTemplate:@""];
}

@end
