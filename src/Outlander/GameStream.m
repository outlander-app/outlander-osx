//
//  GameStream.m
//  Outlander
//
//  Created by Joseph McBride on 1/25/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameStream.h"
#import "GameServer.h"
#import "GameConnection.h"
#import "TextTag.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GameCommandRelay.h"
#import "Outlander-Swift.h"

@interface GameStream () {
    GameServer *_gameServer;
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


    _tokenizer = [StormFrontTokenizer newInstance];
    _tagStreamer = [StormFrontTagStreamer newInstance];
    _scriptStreamHandler = [ScriptStreamHandler newInstance];
    _roomChangeHandler = [RoomChangeHandler newInstance:_commandRelay];
    _tdpUpdateHandler = [TDPUpdateHandler newInstance];
    _expUpdateHandler = [ExpUpdateHandler newInstance];
    _triggerHandler = [TriggerHandler newInstance:context relay:_commandRelay];

    @weakify(self)

    _expUpdateHandler.emitSetting = ^(NSString *key, NSString *value) {
        @strongify(self)
        [self->_gameContext.globalVars set:value forKey:key];
    };
    
    _expUpdateHandler.emitExp = ^(SkillExp *exp) {
        @strongify(self)
        [self.exp sendNext:exp];
    };
    
    _tagStreamer.emitSetting = ^(NSString *key, NSString *value){
        @strongify(self)
        [self->_gameContext.globalVars set:value forKey:key];
    };
    
    _tagStreamer.emitExp = ^(SkillExp *exp) {
        @strongify(self)
        [self.exp sendNext:exp];
    };
    
    _tagStreamer.emitRoundtime = ^(Roundtime *rt) {
        @strongify(self)
        [self.roundtime sendNext:rt];
    };
    
    _tagStreamer.emitRoom = ^{
        @strongify(self)
        [self.room sendNext:@""];
    };
    
    _tagStreamer.emitVitals = ^(Vitals *vital) {
        @strongify(self)
        [self.vitals sendNext:vital];
    };
    
    _tagStreamer.emitSpell = ^(NSString *spell) {
        @strongify(self)
        [self.spell sendNext:spell];
    };
    
    _tagStreamer.emitClearStream = ^(NSString *window) {
        @strongify(self)
        CommandContext *ctx = [[CommandContext alloc] init];
        ctx.command = [NSString stringWithFormat:@"#window clear %@", window];

        [self->_commandRelay sendCommand:ctx];
    };
    
    _tagStreamer.emitWindow = ^(NSString *window, NSString *title, NSString *closedTarget) {
        @strongify(self)
        NSDictionary *win = @{
            @"name" : window,
            @"title" : title != nil ? title : [NSNull null],
            @"closedTarget" : closedTarget != nil ? closedTarget : [NSNull null]
        };
        [self->_gameContext.events publish:@"OL:window:ensure" data:win];
    };

    _tagStreamer.emitLaunchUrl = ^(NSString *url) {
        if ([url hasPrefix:@"/forums"]) {
            url = [NSString stringWithFormat:@"http://play.net%@", url];
        }

        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [[NSWorkspace sharedWorkspace] openURL:[req URL]];
    };
    
    _vitals = [RACSubject subject];
    _indicators = [RACSubject subject];
    _directions = [RACSubject subject];

    _room = [RACSubject subject];
    _spell = [RACSubject subject];
    _exp = [RACSubject subject];
    _thoughts = [RACSubject subject];
    _chatter = [RACSubject subject];
    _arrivals = [RACSubject subject];
    _deaths = [RACSubject subject];
    _familiar = [RACSubject subject];
    _log = [RACSubject subject];
    _roundtime = [RACSubject subject];

    _connected = [RACSubject subject];
    _disconnected = [RACSubject subject];
    _mainSubject = [RACSubject subject];
    _subject = [_mainSubject multicast:[RACSubject subject]];
    [_subject connect];
    
    [_gameContext.events subscribe:self token:@"ol:testxml"];

    return self;
}

- (void)handle:(NSString *)token data:(NSDictionary *)data {
    NSString *xml = [data objectForKey:@"xml"];
    [self processXml:xml];
}

-(void)resetGameServer {

    if(_gameServer) {
        [_gameServer disconnect];
    }

    _gameServer = [[GameServer alloc] initWithContext:_gameContext];
    
    [_gameServer.connected subscribeNext:^(id x) {
        id<RACSubscriber> sub = (id<RACSubscriber>)_connected;
        [sub sendNext:x];
    }];
}

-(void) publish:(id)item {
    [_mainSubject sendNext:item];
}

-(void) reset {
}

-(void) error:(NSError *)error {
    [_mainSubject sendError:error];
}

-(void) sendCommand:(NSString *)command {
    [_gameServer sendCommand:command];
}

-(RACMulticastConnection *) connect:(GameConnection *)connection {

    [self resetGameServer];
    
    [[_gameServer connect:connection.key
                  toHost:connection.host
                  onPort:connection.port]
     subscribeNext:^(NSString *rawXml) {

         [self processXml:rawXml];

     } completed:^{
         id<RACSubscriber> sub = (id<RACSubscriber>)_disconnected;
         [sub sendNext:@""];
     }];
    
    return _subject;
}

-(void)processXml:(NSString *)rawXml {
     TextTag *rawTag = [TextTag tagFor:rawXml mono:YES];
     rawTag.targetWindow = @"raw";
     
     NSArray *rawArray = [NSArray arrayWithObjects:rawTag, nil];
     [_mainSubject sendNext:rawArray];

     NSArray *nodes = [_tokenizer tokenize:rawXml];
     NSArray *tags = [_tagStreamer stream:nodes];
     
     [_mainSubject sendNext:tags];
     
     NSString *rawText = [self textForTagList:tags];

     [_triggerHandler handle:nodes text:rawText context:_gameContext];
     [_roomChangeHandler handle:nodes text:rawText context:_gameContext];
     [_tdpUpdateHandler handle:nodes text:rawText context:_gameContext];
     [_expUpdateHandler handle:nodes text:rawText context:_gameContext];
     [_scriptStreamHandler handle:nodes text:rawText context:_gameContext];
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
