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

@interface GameStream () {
    RACSignal *_connection;
    GameContext *_gameContext;
    RACSubject *_mainSubject;
    StormFrontTokenizer *_tokenizer;
    StormFrontTagStreamer *_tagStreamer;
}

@end

@implementation GameStream

-(id) initWithContext:(GameContext *)context {
    self = [super init];
    if(self == nil) return nil;
    
    _gameContext = context;
    
    _gameServer = [[GameServer alloc] initWithContext:context];
    _gameParser = [[GameParser alloc] initWithContext:context];
    _tokenizer = [StormFrontTokenizer newInstance];
    _tagStreamer = [StormFrontTagStreamer newInstance];
    
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
    [_mainSubject sendCompleted];
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
         
         NSArray *nodes = [_tokenizer tokenize:rawXml];
         NSArray *tags = [_tagStreamer stream:nodes];
         
         //NSString *rawText = [self textForTagList:tags];
         //NSLog(@"text: %@", rawText);
         
         [_mainSubject sendNext:tags];
         
     } completed:^{
        [_mainSubject sendCompleted];
     }];
    
    return _subject;
}

-(NSString *)textForTagList:(NSArray *)tags {
    NSMutableString *text = [[NSMutableString alloc] init];

    for(TextTag *tag in tags){
        [text appendString:tag.text];
    }
    
    return text;
}

@end
