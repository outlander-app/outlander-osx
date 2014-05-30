//
//  ScriptRunner.m
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ScriptRunner.h"
#import "ScriptLoader.h"
#import "TSMutableDictionary.h"
#import "Script.h"
#import "TextTag.h"

@interface ScriptRunner () {
    id<InfoStream> _gameStream;
    GameContext *_context;
    ScriptLoader *_loader;
    TSMutableDictionary *_scripts;
}
@end

@implementation ScriptRunner

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWith:(GameContext *)context and:(id<FileSystem>)fileSystem {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    
    _loader = [[ScriptLoader alloc] initWith:context and:fileSystem];
    _scripts = [[TSMutableDictionary alloc] initWithName:@"com.outlander.scriptrunner"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveScriptNotification:)
                                                 name:@"script"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveStartScriptNotification:)
                                                 name:@"startscript"
                                               object:nil];
    return self;
}

- (void)setGameStream:(id<InfoStream>)stream {
    _gameStream = stream;
}

- (void) receiveStartScriptNotification:(NSNotification *) notification {
    NSString *target = notification.userInfo[@"target"];
    NSArray *args = notification.userInfo[@"args"];
    [self run:target withArgs:args];
}

- (void) receiveScriptNotification:(NSNotification *) notification {
    
    NSString *action = notification.userInfo[@"action"];
    NSString *target = notification.userInfo[@"target"];

    if([action isEqualToString:@"abort"]) {
        [self abort:target];
    }
    
    if([action isEqualToString:@"pause"]) {
        [self pause:target];
    }
    
    if([action isEqualToString:@"resume"]) {
        [self resume:target];
    }
    
    if([action isEqualToString:@"vars"]) {
        [self vars:target];
    }
}

- (void)run:(NSString *)scriptName withArgs:(NSArray *)args {
    
    [self abort:scriptName];
    
    NSString *data = [_loader load:scriptName];
    
    if(!data || data.length == 0) {
        return;
    }
    
    Script *script = [[Script alloc] initWith:_context and:data];
    script.name = scriptName;
    [script setGameStream:_gameStream];
    
    [_scripts setCacheObject:script forKey:scriptName];
    
    [script start];
    [self sendEcho:[NSString stringWithFormat:@"[Script loaded: %@]", scriptName]];
}

- (void)pause:(NSString *)scriptName {
    Script *script = [_scripts cacheObjectForKey:scriptName];
   
    if(script) {
        [self sendEcho:[NSString stringWithFormat:@"[Script paused: %@]", scriptName]];
        [script suspend];
    }
}

- (void)resume:(NSString *)scriptName {
    Script *script = [_scripts cacheObjectForKey:scriptName];
   
    if(script) {
        [self sendEcho:[NSString stringWithFormat:@"[Script resumed: %@]", scriptName]];
        [script resume];
    }
}

- (void)abort:(NSString *)scriptName {
    Script *script = [_scripts cacheObjectForKey:scriptName];
   
    if(script) {
        [self sendEcho:[NSString stringWithFormat:@"[Script aborted: %@]", scriptName]];
        [script cancel];
    }
}

- (void)vars:(NSString *)scriptName {
    Script *script = [_scripts cacheObjectForKey:scriptName];
   
    if(script) {
    }
}

- (void)sendEcho:(NSString *)echo {
    TextTag *tag = [TextTag tagFor:[NSString stringWithFormat:@"%@\n", echo] mono:YES];
    tag.color = @"#0066CC";
    
    NSDictionary *userInfo = @{@"tag": tag};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"echo"
                                                        object:nil
                                                      userInfo:userInfo];
}

@end
