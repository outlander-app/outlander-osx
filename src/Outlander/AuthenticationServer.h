//
//  AuthenticationServer.h
//  Outlander
//
//  Created by Joseph McBride on 1/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GCDAsyncSocket.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Shared.h"

typedef NS_ENUM(NSInteger, AuthStateType) {
    AuthStatePasswordHash = 0,
    AuthStateAuthenticate = 1,
    AuthStateChooseGame = 2,
    AuthStateCharacterList = 3,
    AuthStateChooseCharacter = 4,
    AuthStateEnd = 99
};

typedef NS_ENUM(NSInteger, AuthErrorType) {
    AuthErrorNone = 0,
    AuthErrorPassword = 1,
    AuthErrorAccount = 2,
    AuthErrorEnd = 99
};

@interface AuthenticationServer : NSObject {
    NSString *_host;
    UInt16 _port;
    GCDAsyncSocket *asyncSocket;
    NSString *_account;
    NSString *_password;
    NSString *_game;
    NSString *_character;
    NSString *_characterId;
    RACReplaySubject *_connected;
    RACReplaySubject *_subject;
}

- (RACSignal*) connectTo: (NSString *)host onPort:(UInt16)port;
- (RACSignal*) authenticate:(NSString *)account password:(NSString *)password game:(NSString *) game character:(NSString *)character;
@end
