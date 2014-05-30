//
//  GameStream.m
//  Outlander
//
//  Created by Joseph McBride on 1/25/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameStream.h"
#import "GameServer.h"
#import "GameParser.h"
#import "GameConnection.h"
#import "TextTag.h"
#import "ReactiveCocoa.h"

@interface GameStream () {
    RACSignal *_connection;
    GameContext *_gameContext;
}

@end

@implementation GameStream

-(id) initWithContext:(GameContext *)context {
    self = [super init];
    if(self == nil) return nil;
    
    _gameContext = context;
    
    _gameServer = [[GameServer alloc] initWithContext:context];
    _gameParser = [[GameParser alloc] initWithContext:context];
    
    _vitals = _gameParser.vitals;
    
    _room = [_gameParser.room multicast:[RACSubject subject]];
    [_room connect];
    _exp = _gameParser.exp;
    _thoughts = _gameParser.thoughts;
    _arrivals = _gameParser.arrivals;
    _deaths = _gameParser.deaths;
    _familiar = _gameParser.familiar;
    _log = _gameParser.log;
    _roundtime = _gameParser.roundtime;
    
    _connected = [RACReplaySubject subject];
    _subject = [RACReplaySubject subject];
    
    [_gameServer.connected subscribeNext:^(id x) {
        id<RACSubscriber> sub = (id<RACSubscriber>)_connected;
        [sub sendNext:x];
    }];
    
    return self;
}

-(void) publish:(id)item {
    id<RACSubscriber> sub = (id<RACSubscriber>)_subject;
    [sub sendNext:item];
}

-(void) complete {
    [_gameServer disconnect];
    id<RACSubscriber> sub = (id<RACSubscriber>)_subject;
    [sub sendCompleted];
}

-(void) error:(NSError *)error {
    id<RACSubscriber> sub = (id<RACSubscriber>)_subject;
    [sub sendError:error];
}

-(void) sendCommand:(NSString *)command {
    [_gameServer sendCommand:command];
}

-(RACSignal *) connect:(GameConnection *)connection {
    id<RACSubscriber> sub = (id<RACSubscriber>)_subject;
    
    [[_gameServer connect:connection.key
                  toHost:connection.host
                  onPort:connection.port]
     subscribeNext:^(id result) {
        [_gameParser parse:result then:^(NSArray *result) {
            [sub sendNext:result];
        }];
     } completed:^{
        [sub sendCompleted];
     }];
    
    return _subject;
}

@end
