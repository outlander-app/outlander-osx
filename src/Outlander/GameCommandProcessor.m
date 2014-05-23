//
//  GameCommandProcessor.m
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameCommandProcessor.h"

@interface GameCommandProcessor (){
    GameContext *_gameContext;
    VariableReplacer *_replacer;
}
@end

@implementation GameCommandProcessor

-(id)initWith:(GameContext *)context and:(VariableReplacer *)replacer {
    self = [super init];
    if(!self) return nil;
    
    _gameContext = context;
    _replacer = replacer;
    
    return self;
}

- (RACSignal *)process:(NSString *)command {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    command = [_replacer replace:command withContext:_gameContext];
    
    [subject sendNext:command];
    
    return subject;
}
@end
