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
    NSString *allArgs = notification.userInfo[@"allArgs"];
    [self run:target withArgs:args and:allArgs];
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
    
    if([action isEqualToString:@"finish"]) {
        [self finish:target];
    }
}

- (void)run:(NSString *)scriptName withArgs:(NSArray *)args and:(NSString *)allArgs {
    
    [self abort:scriptName];
    
    NSString *data = [_loader load:scriptName];
    
    if(!data || data.length == 0) {
        return;
    }
    
    Script *script = [[Script alloc] initWith:_context and:data];
    script.name = scriptName;
    [script.localVars setCacheObject:scriptName forKey:@"scriptname"];
    [script setGameStream:_gameStream];
   
    [self setArgs:args and:allArgs forScript:script];
    
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
        NSTimeInterval since = [script.started timeIntervalSinceNow];
        
        [self sendEcho:[NSString stringWithFormat:@"[Script aborted! (run time was %#2.2f seconds): %@]", since*-1, scriptName]];
        [_scripts removeObjectForKey:scriptName];
        
        if(![script isCancelled]) {
            [script cancel];
        }
    }
}

- (void)finish:(NSString *)scriptName {
    Script *script = [_scripts cacheObjectForKey:scriptName];
   
    if(script) {
        
        NSTimeInterval since = [script.started timeIntervalSinceNow];
        
        [self sendEcho:[NSString stringWithFormat:@"[Script finished (run time was %#2.2f seconds): %@]", since*-1, scriptName]];
        [_scripts removeObjectForKey:scriptName];
        
        if(![script isCancelled]) {
            [script cancel];
        }
    }
}

- (void)vars:(NSString *)scriptName {
    Script *script = [_scripts cacheObjectForKey:scriptName];
   
    if(script) {
        [self sendEcho:[NSString stringWithFormat:@"\n[Script variables for %@]:", scriptName]];
        [script.localVars.allKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
            [self sendEcho:[NSString stringWithFormat:@"%@=%@", key, [script.localVars cacheObjectForKey:key]]];
        }];
        
        NSTimeInterval since = [script.started timeIntervalSinceNow];
        [self sendEcho:[NSString stringWithFormat:@"[Script run time is %#2.2f seconds: %@]\n", since*-1, scriptName]];
    }
}

- (void)sendEcho:(NSString *)echo {
    TextTag *tag = [TextTag tagFor:[NSString stringWithFormat:@"%@\n", echo] mono:YES];
    tag.color = @"#ffffff";
    
    NSDictionary *userInfo = @{@"tag": tag};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"echo"
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)setArgs:(NSArray *)args and:(NSString *)allArgs forScript:(Script *)script {
    
    [script.localVars setCacheObject:allArgs forKey:@"0"];
    
    [args enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = [NSString stringWithFormat:@"%lu", idx + 1];
        [script.localVars setCacheObject:obj forKey:key];
    }];
    
    [script.localVars setCacheObject:[NSString stringWithFormat:@"%lu", args.count] forKey:@"argcount"];
}

@end
