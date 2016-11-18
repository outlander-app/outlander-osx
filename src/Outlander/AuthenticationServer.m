//
//  AuthenticationServer.m
//  Outlander
//
//  Created by Joseph McBride on 1/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AuthenticationServer.h"
#import "GameConnection.h"
#import "Outlander-Swift.h"

@interface AuthenticationServer () {
    AuthErrorType _authError;
}
@end

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
    
    _authError = AuthErrorNone;
    
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
    
    if(tag == AuthStatePasswordHash) {
        
        NSMutableData *newData = [[NSMutableData alloc] init];
        
        NSString *initialData = [NSString stringWithFormat:@"A\t%@\t", _account];
        [newData appendData:[initialData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
        
        NSString *hash = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSData *hashData = [self encrypt_password:_password with:hash];
        
        [newData appendData:hashData];
        [newData appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
        
        [asyncSocket writeData:newData withTimeout:-1 tag:-1];
        [asyncSocket readDataWithTimeout:-1 tag:AuthStateAuthenticate];
    }
    
    if(tag == AuthStateAuthenticate){
        if([response rangeOfString:@"KEY"].location == NSNotFound) {
            _authError = AuthErrorEnd;
            
            if([response rangeOfString:@"PASSWORD"].location != NSNotFound) {
                _authError = AuthErrorPassword;
            }
            else if([response rangeOfString:@"NORECORD"].location != NSNotFound) {
                _authError = AuthErrorAccount;
            }
            
            [asyncSocket disconnectAfterReadingAndWriting];
            return;
        }
        
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
    if((err != nil && err.code == 8) || _authError > AuthErrorNone) {
        
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setObject:[NSString stringWithFormat:@"failed to connect to %@ on port %hu", _host, _port]
                 forKey:@"message"];
        
        if(_authError == AuthErrorPassword) {
            [info setObject:[NSString stringWithFormat:@"Invalid password"]
                     forKey:@"authMessage"];
        }
        if(_authError == AuthErrorAccount) {
            [info setObject:[NSString stringWithFormat:@"Invalid account"]
                     forKey:@"authMessage"];
        }
        
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

- (NSData *)dataFromHexString:(NSString *)str {
    const char *chars = [str UTF8String];
    int i = 0;
    unsigned long len = [str length];
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}

- (NSData *)encrypt_password:(NSString *)password with:(NSString *)hashString {
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    char* passwd = (char*)[password UTF8String];
    char* hash = (char*)[hashString UTF8String];
    
    int i;
    for (i = 0; i < 32 && passwd[i] != '\0' && hash[i] != '\0'; i++) {
        
        int h = (int)hash[i];
        int p = (int)passwd[i];
        //int or = h^(p-32);
        
        int res = (h^(p-32))+32;
        
        [arr addObject:[NSNumber numberWithInt:res]];
        
        //NSLog(@"%d ^ %d = %d + 32 = %d", h, (p-32), or, res);
    }
    
    NSMutableString *hexHash = [[NSMutableString alloc] init];
    
    for (NSNumber *num in arr) {
        [hexHash appendFormat:@"%X", [num intValue]];
    }
    
    return [self dataFromHexString:hexHash];
}
@end
