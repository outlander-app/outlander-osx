//
//  GameCommandProcessor.m
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameCommandProcessor.h"
#import "CommandHandler.h"
#import "CommandContext.h"
#import "ScriptCommandHandler.h"
#import "ScriptHandler.h"
#import "HighlightCommandHandler.h"
#import "VarCommandHandler.h"
#import "AliasCommandHandler.h"
#import "SendCommandHandler.h"
#import "CommandRelay.h"
#import "GameCommandRelay.h"
#import "GameEventRelay.h"
#import "Outlander-Swift.h"
#import "NSString+Categories.h"

@interface GameCommandProcessor (){
    GameContext *_gameContext;
    VariableReplacer *_replacer;
    NSMutableArray *_handlers;
}
@end

@implementation GameCommandProcessor

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_gameContext.events unSubscribeListener:self];
    [_handlers removeAllObjects];
}

-(id)initWith:(GameContext *)context and:(VariableReplacer *)replacer {
    self = [super init];
    if(!self) return nil;
    
    _gameContext = context;
    _replacer = replacer;
    _processed = [RACReplaySubject subject];
    _echoed = [RACReplaySubject subject];
    
    GameCommandRelay *relay = [[GameCommandRelay alloc] initWith:_gameContext.events];
    
    _handlers = [[NSMutableArray alloc] init];
    [_handlers addObject:[[ScriptHandler alloc] initWith:[[GameEventRelay alloc] initWith:context.events]]];
    [_handlers addObject:[[ScriptCommandHandler alloc] init]];
    [_handlers addObject:[[VarCommandHandler alloc] init]];
    [_handlers addObject:[[HighlightCommandHandler alloc] init]];
    [_handlers addObject:[[AliasCommandHandler alloc] init]];
    [_handlers addObject:[[SendCommandHandler alloc] initWith:relay]];
    [_handlers addObject:[EchoCommandHandler newInstance:relay]];
    [_handlers addObject:[MapperCommandHandler newInstance]];
    [_handlers addObject:[MapperGotoCommandHandler newInstance:relay]];
    [_handlers addObject:[ParseCommandHandler newInstance]];
    [_handlers addObject:[BeepCommandHandler newInstance]];
    [_handlers addObject:[FlashCommandHandler newInstance]];
    [_handlers addObject:[WindowCommandHandler newInstance]];
    [_handlers addObject:[TestCommandHandler newInstance]];
    [_handlers addObject:[PresetCommandHandler newInstance]];
    
    [context.events subscribe:self token:@"OL:command"];
    [context.events subscribe:self token:@"OL:echo"];
    
    return self;
}

- (void)handle:(NSString *)token data:(NSDictionary *)data {
    if ([token isEqualToString:@"OL:command"]) {
        [self recieveCommand:data];
    } else if ([token isEqualToString:@"OL:echo"]) {
        [self recieveEcho:data];
    }
}

- (void)recieveCommand:(NSDictionary *)userInfo {
    CommandContext *command = userInfo[@"command"];
    [self process:command];
}

- (void)recieveEcho:(NSDictionary *)userInfo {
    TextTag *tag = userInfo[@"tag"];
    [self echo:tag];
}

- (void)process:(CommandContext *)context {
    
    __block BOOL handled = NO;
    
    context.command = [_replacer replace:context.command withContext:_gameContext];
    
    if(context.tag) {
        context.tag.text = [_replacer replace:context.tag.text withContext:_gameContext];
    }
    
    [_handlers enumerateObjectsUsingBlock:^(id<CommandHandler> handler, NSUInteger idx, BOOL *stop) {
        if([handler canHandle:context.command]) {
            handled = YES;
            *stop = YES;
            [handler handle:context.command withContext:_gameContext];
        }
    }];
    
    if(!handled) {
        id<RACSubscriber> sub = (id<RACSubscriber>)_processed;
        [sub sendNext:context];
    }
}

- (void)echo:(TextTag *)tag {
    id<RACSubscriber> sub = (id<RACSubscriber>)_echoed;

    if(tag.preset == nil || [tag.preset length] == 0) {
        tag.preset = @"scriptecho";
    }

    [sub sendNext:tag];
}
@end
