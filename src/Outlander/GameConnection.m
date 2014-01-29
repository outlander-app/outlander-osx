//
//  GameConnection.m
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameConnection.h"

@implementation GameConnection
+ (id)connectionForGame:(NSString *)game host:(NSString *)host port:(UInt16) port key:(NSString *)key {
    return [[self alloc] initForGame:game host:host port:port key:key];
}

- (id)initForGame:(NSString *)game host:(NSString *)host port:(UInt16)port key:(NSString *)key {
    self = [super init];
    if(self){
        _game = game;
        _host = host;
        _port = port;
        _key = key;
    }
    
    return self;
}
- (NSString *)description {
    return [[NSString alloc] initWithFormat:@"Game=%@ Host=%@ Port=%hu Key=%@", _game, _host, _port, _key];
}
@end
