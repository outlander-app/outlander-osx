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
#import "GameEventRelay.h"

@interface GameCommandProcessor (){
    GameContext *_gameContext;
    VariableReplacer *_replacer;
    NSMutableArray *_handlers;
}
@end

@implementation GameCommandProcessor

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)initWith:(GameContext *)context and:(VariableReplacer *)replacer {
    self = [super init];
    if(!self) return nil;
    
    _gameContext = context;
    _replacer = replacer;
    _processed = [RACReplaySubject subject];
    _echoed = [RACReplaySubject subject];
    
    _handlers = [[NSMutableArray alloc] init];
    [_handlers addObject:[[ScriptHandler alloc] initWith:[[GameEventRelay alloc] init]]];
    [_handlers addObject:[[ScriptCommandHandler alloc] init]];
    [_handlers addObject:[[VarCommandHandler alloc] init]];
    [_handlers addObject:[[HighlightCommandHandler alloc] init]];
    [_handlers addObject:[[AliasCommandHandler alloc] init]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCommandNotification:)
                                                 name:@"command"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveEchoNotification:)
                                                 name:@"echo"
                                               object:nil];
    
    return self;
}

- (void) receiveCommandNotification:(NSNotification *) notification {
    CommandContext *command = notification.userInfo[@"command"];
    [self process:command];
}

- (void) receiveEchoNotification:(NSNotification *) notification {
    TextTag *tag = notification.userInfo[@"tag"];
    [self echo:tag];
}

- (void)process:(CommandContext *)context {
    
    __block BOOL handled = NO;
    
    [_handlers enumerateObjectsUsingBlock:^(id<CommandHandler> handler, NSUInteger idx, BOOL *stop) {
        if([handler canHandle:context.command]) {
            handled = YES;
            *stop = YES;
            [handler handle:context.command withContext:_gameContext];
        }
    }];
    
    if(!handled) {
        context.command = [_replacer replace:context.command withContext:_gameContext];
        
        id<RACSubscriber> sub = (id<RACSubscriber>)_processed;
        [sub sendNext:context];
    }
}

- (void)echo:(TextTag *)tag {
    id<RACSubscriber> sub = (id<RACSubscriber>)_echoed;
    [sub sendNext:tag];
}
@end
