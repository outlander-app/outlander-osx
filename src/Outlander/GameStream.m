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
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GameCommandRelay.h"
#import "Outlander-Swift.h"

@interface GameStream () {
    RACSignal *_connection;
    GameContext *_gameContext;
    GameCommandRelay *_commandRelay;
    RACSubject *_mainSubject;
    StormFrontTokenizer *_tokenizer;
    StormFrontTagStreamer *_tagStreamer;
    ScriptStreamHandler *_scriptStreamHandler;
    RoomChangeHandler *_roomChangeHandler;
    TDPUpdateHandler *_tdpUpdateHandler;
    ExpUpdateHandler *_expUpdateHandler;
    TriggerHandler *_triggerHandler;
}

@end

@implementation GameStream

-(id) initWithContext:(GameContext *)context {
    self = [super init];
    if(self == nil) return nil;
    
    _gameContext = context;
    _commandRelay = [[GameCommandRelay alloc] initWith:context.events];
    
    _gameServer = [[GameServer alloc] initWithContext:context];
    _gameParser = [[GameParser alloc] initWithContext:context];
    _tokenizer = [StormFrontTokenizer newInstance];
    _tagStreamer = [StormFrontTagStreamer newInstance];
    _scriptStreamHandler = [ScriptStreamHandler newInstance];
    _roomChangeHandler = [RoomChangeHandler newInstance:_commandRelay];
    _tdpUpdateHandler = [TDPUpdateHandler newInstance];
    _expUpdateHandler = [ExpUpdateHandler newInstance];
    _triggerHandler = [TriggerHandler newInstance:context relay:_commandRelay];
    
    _expUpdateHandler.emitSetting = ^(NSString *key, NSString *value){
        [_gameContext.globalVars setCacheObject:value forKey:key];
    };
    
    _expUpdateHandler.emitExp = ^(SkillExp *exp) {
        [_exp sendNext:exp];
    };
    
    _tagStreamer.emitSetting = ^(NSString *key, NSString *value){
        [_gameContext.globalVars setCacheObject:value forKey:key];
    };
    
    _tagStreamer.emitExp = ^(SkillExp *exp) {
        [_exp sendNext:exp];
    };
    
    _tagStreamer.emitRoundtime = ^(Roundtime *rt) {
        [_roundtime sendNext:rt];
    };
    
    _tagStreamer.emitRoom = ^{
        [_gameParser.room sendNext:@""];
    };
    
    _tagStreamer.emitVitals = ^(Vitals *vital) {
        [_vitals sendNext:vital];
    };
    
    _tagStreamer.emitSpell = ^(NSString *spell) {
        [_gameParser.spell sendNext:spell];
    };
    
    _tagStreamer.emitClearStream = ^(NSString *window) {
        CommandContext *ctx = [[CommandContext alloc] init];
        ctx.command = [NSString stringWithFormat:@"#window clear %@", window];
        
        [_commandRelay sendCommand:ctx];
    };
    
    _tagStreamer.emitWindow = ^(NSString *window, NSString *title, NSString *closedTarget) {
        NSDictionary *win = @{
            @"name" : window,
            @"title" : title != nil ? title : [NSNull null],
            @"closedTarget" : closedTarget != nil ? closedTarget : [NSNull null]
        };
        [_gameContext.events publish:@"OL:window:ensure" data:win];
    };
    
    _vitals = _gameParser.vitals;
    _indicators = _gameParser.indicators;
    _directions = _gameParser.directions;
    
    _room = [_gameParser.room multicast:[RACSubject subject]];
    [_room connect];
    _spell = [_gameParser.spell multicast:[RACSubject subject]];
    [_spell connect];
    _exp = _gameParser.exp;
    _thoughts = _gameParser.thoughts;
    _chatter = _gameParser.chatter;
    _arrivals = _gameParser.arrivals;
    _deaths = _gameParser.deaths;
    _familiar = _gameParser.familiar;
    _log = _gameParser.log;
    _roundtime = _gameParser.roundtime;
    
    _connected = [RACSubject subject];
    _mainSubject = [RACSubject subject];
    _subject = [_mainSubject multicast:[RACSubject subject]];
    [_subject connect];
    
    [_gameServer.connected subscribeNext:^(id x) {
        id<RACSubscriber> sub = (id<RACSubscriber>)_connected;
        [sub sendNext:x];
    }];
    
    return self;
}

-(void) publish:(id)item {
    [_mainSubject sendNext:item];
}

-(void) complete {
    [_gameServer disconnect];
    [_triggerHandler unsubscribe];
    [_mainSubject sendCompleted];
}

-(void) unsubscribe {
    [_triggerHandler unsubscribe];
}

-(void) error:(NSError *)error {
    [_mainSubject sendError:error];
}

-(void) sendCommand:(NSString *)command {
    [_gameServer sendCommand:command];
}

-(RACMulticastConnection *) connect:(GameConnection *)connection {
    
    [[_gameServer connect:connection.key
                  toHost:connection.host
                  onPort:connection.port]
     subscribeNext:^(NSString *rawXml) {
         
         TextTag *rawTag = [TextTag tagFor:rawXml mono:YES];
         rawTag.targetWindow = @"raw";
         
         NSArray *rawArray = [NSArray arrayWithObjects:rawTag, nil];
         [_mainSubject sendNext:rawArray];
         
         NSArray *nodes = [_tokenizer tokenize:rawXml];
         NSArray *tags = [_tagStreamer stream:nodes];
         
         [_mainSubject sendNext:tags];
         
         NSString *rawText = [self textForTagList:tags];
         //NSLog(@"-->%@", rawText);
         [_triggerHandler handle:nodes text:rawText context:_gameContext];
         [_roomChangeHandler handle:nodes text:rawText context:_gameContext];
         [_tdpUpdateHandler handle:nodes text:rawText context:_gameContext];
         [_expUpdateHandler handle:nodes text:rawText context:_gameContext];
         [_scriptStreamHandler handle:nodes text:rawText context:_gameContext];
         
     } completed:^{
         [self unsubscribe];
         [_mainSubject sendCompleted];
     }];
    
    return _subject;
}

-(NSString *)textForTagList:(NSArray *)tags {
    NSMutableString *text = [[NSMutableString alloc] init];

    for(TextTag *tag in tags) {
        if (tag != nil && [tag.text length] > 0) {
            [text appendString:tag.text];
        }
    }
    
    return text;
}

@end
