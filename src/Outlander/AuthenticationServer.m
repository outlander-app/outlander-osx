//
//  AuthenticationServer.m
//  Outlander
//
//  Created by Joseph McBride on 1/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AuthenticationServer.h"
#import "GCDAsyncSocket.h"
#import "GameConnection.h"

@implementation AuthenticationServer

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    return self;
}

- (RACSignal*) connectTo: (NSString *)host onPort:(UInt16)port {
    _host = host;
    _port = port;
    _connected = [RACReplaySubject subject];
    [asyncSocket connectToHost:host onPort:port error:nil];
    return _connected;
}

- (RACSignal*) authenticate:(NSString *)account password:(NSString *)password game:(NSString *) game character:(NSString *)character {
    
    _account = account;
    _password = password;
    _game = game;
    _character = character;
    
    _subject = [RACReplaySubject subject];
    
    NSData *requestData = [@"K\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:requestData withTimeout:-1.0 tag:-1];
    [asyncSocket readDataWithTimeout:-1 tag:AuthStatePasswordHash];
    
    return _subject;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Connected");
    [_connected sendNext: [NSString stringWithFormat: @"connected to %@ on port %hu", _host, _port]];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"socket:didReadData:withTag: %ld", tag);
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Response: %@", response);
    
    if(tag == AuthStatePasswordHash){
        char* hash = sge_encrypt_password((char*)[_password UTF8String], (char*)[response UTF8String]);
        NSData *data = [[NSString stringWithFormat:@"A\t%@\t%s\r\n", _account, hash] dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:data withTimeout:-1 tag:-1];
        [asyncSocket readDataWithTimeout:-1 tag:AuthStateAuthenticate];
    }
    
    if(tag == AuthStateAuthenticate){
        NSData *data = [[NSString stringWithFormat:@"G\t%@\r\n", _game] dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:data withTimeout:-1 tag:-1];
        [asyncSocket readDataWithTimeout:-1 tag:AuthStateChooseGame];
    }
    
    if(tag == AuthStateChooseGame){
        NSData *data = [@"C\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:data withTimeout:-1 tag:-1];
        [asyncSocket readDataWithTimeout:-1 tag:AuthStateCharacterList];
    }
    
    if(tag == AuthStateCharacterList){
        
        NSString *characterId = [self characterId: _character from:response];
        NSData *data = [[NSString stringWithFormat:@"L\t%@\tPLAY\r\n", characterId] dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:data withTimeout:-1 tag:-1];
        [asyncSocket readDataWithTimeout:-1 tag:AuthStateChooseCharacter];
    }
    
    if(tag == AuthStateChooseCharacter){
        GameConnection *conn = [GameConnection connectionForGame:_game
                                                            host:[self valueFrom:response pattern:@"GAMEHOST=(\\S+)"]
                                                            port:[self portFrom:response]
                                                             key:[self valueFrom:response pattern:@"KEY=(\\w+)"]];
        [asyncSocket disconnectAfterReadingAndWriting];
        [_subject sendNext:conn];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect:withError:%@", err);
    if(err != nil && err.code == 8) {
        
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setObject:[NSString stringWithFormat:@"failed to connect to %@ on port %hu", _host, _port]
                 forKey:@"message"];
        
        NSError *authErr = [NSError errorWithDomain:@"auth" code:0 userInfo:info];
        [_connected sendError:authErr];
    }
    [_connected sendCompleted];
    [_subject sendCompleted];
}

- (NSString *) characterId:(NSString *) character from:(NSString *)data {
    NSString *pattern = [NSString stringWithFormat:@"(\\S_\\S[\\S0-9]*)\t%@", character];
    return [self valueFrom:data pattern:pattern];
}

- (UInt16) portFrom: (NSString *)data {
    NSString *port = [self valueFrom:data pattern:@"GAMEPORT=(\\w+)"];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:port];
    return [myNumber unsignedIntValue];
}

- (NSString *) valueFrom:(NSString *)data pattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:data
                                                    options:0
                                                      range:NSMakeRange(0, [data length])];
    
    NSString *key = nil;
    
    if (match) {
        NSRange matchRange = [match rangeAtIndex:1];
        key = [data substringWithRange:matchRange];
    }
    return key;
}

char* sge_encrypt_password(char *passwd, char *hash) {
    char *final = (char*)malloc(sizeof (char)* 33);
    
    int i;
    for (i = 0; i < 32 && passwd[i] != '\0' && hash[i] != '\0'; i++) {
        final[i] = (char)((hash[i] ^ (passwd[i] - 32)) + 32);
    }
    final[i] = '\0';
    
    return final;
}
@end
