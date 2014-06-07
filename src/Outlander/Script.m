//
//  Script.m
//  Outlander
//
//  Created by Joseph McBride on 6/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Script.h"
#import "ExpressionBuilder.h"

@interface Script () {
    id<InfoStream> _gameStream;
    id<CommandRelay> _commandRelay;
    GameContext *_context;
    ExpressionBuilder *_builder;
}
@end

@implementation Script

- (instancetype)initWith:(GameContext *)context and:(NSString *)data {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    _localVars = [[TSMutableDictionary alloc] initWithName:[NSString stringWithFormat:@"com.outlander.script.localvars.%@", self.uuid]];
    _builder = [[ExpressionBuilder alloc] init];
    
    [self setData:data];
    
    return self;
}

- (void)setGameStream:(id<InfoStream>)stream {
    _gameStream = stream;
}

- (void)setCommandRelay:(id<CommandRelay>)relay {
    _commandRelay = relay;
}

- (void)setData:(NSString *)data {
    _syntaxTree = [_builder build:data];
}
@end
