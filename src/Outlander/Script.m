//
//  Script.m
//  Outlander
//
//  Created by Joseph McBride on 6/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Script.h"
#import "ExpressionBuilder.h"
#import "GameCommandRelay.h"
#import "NSString+Categories.h"
#import "VariableReplacer.h"

typedef void (^waitActionBlock) ();

@interface Script () {
    id<InfoStream> _gameStream;
    id<CommandRelay> _commandRelay;
    GameContext *_context;
    ExpressionBuilder *_builder;
    NSUInteger _tokenIndex;
    VariableReplacer *_varReplacer;
    NSDictionary *_labels;
    NSCondition *_pauseCondition;
    NSUInteger _debugLevel;
}
@end

@implementation Script

- (instancetype)initWith:(GameContext *)context and:(NSString *)data {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    _localVars = [[TSMutableDictionary alloc] initWithName:[NSString stringWithFormat:@"com.outlander.script.localvars.%@", self.uuid]];
    _currentVars = [[TSMutableDictionary alloc] initWithName:[NSString stringWithFormat:@"com.outlander.script.currentvars.%@", self.uuid]];
    _gosubStack = [[SimpleStack alloc] init];
    _labels = [[NSDictionary alloc] init];
    _builder = [[ExpressionBuilder alloc] init];
    _varReplacer = [[VariableReplacer alloc] init];
    _commandRelay = [[GameCommandRelay alloc] init];
    _pauseCondition = [[NSCondition alloc] init];
    
    _debugLevel = 0;
    
    [self setData:data];
    
    return self;
}

- (void)cancel {
  
    // TODO: wrap pause/signal so the script can truely be canceled
//    [_pauseCondition signal];
//    [_pauseCondition unlock];
    
    [super cancel];
}

- (void)setGameStream:(id<InfoStream>)stream {
    _gameStream = stream;
}

- (void)setCommandRelay:(id<CommandRelay>)relay {
    _commandRelay = relay;
}

- (void)setData:(NSString *)data {
    _syntaxTree = [_builder build:data];
    
    _tokenIndex = 0;
}

- (void)process {
    if(_tokenIndex >= _syntaxTree.count || self.isCancelled) {
        NSLog(@"End of script!");
        if(!self.isCancelled) {
            [self cancel];
        }
        return;
    }
    
    [self processToken:_syntaxTree[_tokenIndex]];
    
    _tokenIndex++;
}

-(void)processToken:(id<Token>)token {
    NSString *str = [NSString stringWithFormat:@"handle%@:", NSStringFromClass([token class])];
    NSLog(@"Process Token=%@ with=%@", token, str);
    SEL sel = NSSelectorFromString(str);
    [self fireSelector:sel with:token];
}

- (void)fireSelector:(SEL)sel with:(id)token {
    if ([self respondsToSelector:sel]) {
        IMP imp = [self methodForSelector:sel];
        void (*func)(id, SEL, id<Token>) = (void *)imp;
        func(self, sel, token);
    }
}

-(NSInteger)findLabel:(NSString *)label {
    
    __block NSInteger foundIdx = -1;
    
    [_syntaxTree enumerateObjectsUsingBlock:^(id<Token> obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[LabelToken class]] && [[obj eval] isEqualToString:label]) {
            *stop = YES;
            foundIdx = idx;
        }
    }];
    
    return foundIdx;
}

-(void)handleLabelToken:(LabelToken *)token {
    NSString *debug = [NSString stringWithFormat:@"passing label %@", [token eval]];
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
}

-(void)handleGotoToken:(GotoToken *)token {
    NSString *label = [self replaceVars:[token eval]];
    
    NSString *debug = [NSString stringWithFormat:@"goto label %@", label];
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
    
    [_currentVars removeAllObjects];
    
    [self gotoLabel:label forLineNumber:token.lineNumber];
}

-(void)gotoLabel:(NSString *)label forLineNumber:(NSUInteger)lineNumber {
    
    NSInteger idx = [self findLabel:label];
    
    if(idx < 0) {
        NSString *debug = [NSString stringWithFormat:@"unknown label %@", label];
        [self sendScriptDebug:debug forLineNumber:lineNumber];
        [self cancel];
    }
    
    _tokenIndex = --idx;
}

-(void)handleEchoToken:(EchoToken *)token {
    [self sendEcho:[self replaceVars:[token eval]]];
}

-(void)handlePutToken:(PutToken *)token {
    [self sendCommand:[self replaceVars:[token eval]]];
    
    [self waitForRoundtime:nil];
}

-(void)handlePauseToken:(PauseToken *)token {
    
    NSTimeInterval interval = [[token eval] doubleValue];
    
    NSString *debug = [NSString stringWithFormat:@"pausing for %#2.2f", interval];
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
    
    [NSThread sleepForTimeInterval:interval];
}

-(void)handleMatchWaitToken:(MatchWaitToken *) token {
    
    __block BOOL gotSignal = NO;
    __block BOOL timedOut = YES;
    __block RACDisposable *signal = nil;
   
    NSTimeInterval waitTime = 0;
    if(token.waitTime) {
        waitTime = [token.waitTime doubleValue];
    }
    
    signal = [_gameStream.subject.signal subscribeNext:^(NSArray *arr) {
        
        [arr enumerateObjectsUsingBlock:^(TextTag *obj, NSUInteger idx, BOOL *stop1) {
            
            [token.tokens enumerateObjectsUsingBlock:^(MatchToken *match, NSUInteger idx, BOOL *stop2) {
                
                NSString *pattern = [match.right eval];
                
                NSArray *matches = [obj.text matchesForPattern:pattern];
                
                [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop3) {
                    if(res.numberOfRanges > 0) {
                        *stop1 = YES;
                        *stop2 = YES;
                        *stop3 = YES;
                        timedOut = NO;
                        gotSignal = YES;
                        [signal dispose];
                        
                        NSString *label = [match.left eval];
                        
                        [self sendScriptDebug:[NSString stringWithFormat:@"match goto %@", label] forLineNumber:token.lineNumber];
                        [_pauseCondition signal];
                        
                        [self gotoLabel:label forLineNumber:token.lineNumber];
                    }
                }];
            }];
        }];
    }];
    
    NSString *debug = @"matchwait";
    
    if(waitTime > 0) {
        debug = [NSString stringWithFormat:@"matchwait %#2.2f", waitTime];
    }
    
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
    
    [_pauseCondition lock];
    
    while(!gotSignal) {
        if(waitTime > 0) {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:waitTime];
            [_pauseCondition waitUntilDate:date];
            if(timedOut) {
                gotSignal = YES;
                [signal dispose];
                if(!self.isCancelled) {
                    [self sendScriptDebug:@"matchwait timed out" forLineNumber:token.lineNumber];
                }
            }
        }
        else {
            [_pauseCondition wait];
        }
    }
    
    [_pauseCondition unlock];
}

- (void)handleMoveToken:(MoveToken *)token {
    
    NSString *direction = [self replaceVars:[token eval]];
    
    NSString *debug = [NSString stringWithFormat:@"move %@ - waiting for room description", direction];
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
    
    __block BOOL gotRoom = NO;
    __block RACDisposable *signal = nil;
    
    signal = [_gameStream.room.signal subscribeNext:^(id x) {
        gotRoom = YES;
        [signal dispose];
        [_pauseCondition signal];
    }];
    
    [self sendCommand:direction];
    
    [_pauseCondition lock];
    
    while(!gotRoom) {
        [_pauseCondition wait];
    }
    
    [_pauseCondition unlock];
}

- (void)handleNextRoomToken:(NextRoomToken *)token {
    
    NSString *debug = @"nextroom - waiting for room description";
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
    
    __block BOOL gotRoom = NO;
    __block RACDisposable *signal = nil;
    
    signal = [_gameStream.room.signal subscribeNext:^(id x) {
        gotRoom = YES;
        [signal dispose];
        [_pauseCondition signal];
    }];
    
    [_pauseCondition lock];
    
    while(!gotRoom) {
        [_pauseCondition wait];
    }
    
    [_pauseCondition unlock];
}

-(void)handleWaitForToken:(WaitForToken *)token {
    __block BOOL gotSignal = NO;
    __block RACDisposable *signal = nil;
    
    NSString *matchText = [token eval];
   
    signal = [_gameStream.subject.signal subscribeNext:^(NSArray *arr) {
        
        [arr enumerateObjectsUsingBlock:^(TextTag *obj, NSUInteger idx, BOOL *stop1) {
            
            NSArray *matches = [obj.text matchesForPattern:matchText];
            
            [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop3) {
                if(res.numberOfRanges > 0) {
                    *stop1 = YES;
                    *stop3 = YES;
                    gotSignal = YES;
                    [signal dispose];
                    
//                    [self sendScriptDebug:[NSString stringWithFormat:@"matched",] forLineNumber:token.lineNumber];
                    [_pauseCondition signal];
                }
            }];
        }];
    }];
    
    NSString *debug = [NSString stringWithFormat:@"waitfor %@", matchText];
    
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
    
    [_pauseCondition lock];
    
    while(!gotSignal) {
        [_pauseCondition wait];
    }
    
    [_pauseCondition unlock];
}

- (void)handleExitToken:(ExitToken *)token {
    NSString *debug = @"exit";
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
    [self cancel];
}

- (void)handleGosubToken:(GosubToken *)token {
    NSString *label = [token.left eval];
    NSString *debug = [NSString stringWithFormat:@"gosub %@", label];
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
    
    token.stackIndex = _tokenIndex;
    
    [_gosubStack push:token];
    
    // clear all current vars
    [_currentVars removeAllObjects];
    
    // set current args
    TokenList *args = token.right;
    [_currentVars setCacheObject:[args eval] forKey:@"0"];
    [args.tokens enumerateObjectsUsingBlock:^(id<Token> obj, NSUInteger idx, BOOL *stop) {
        [_currentVars setCacheObject:[obj eval] forKey:[NSString stringWithFormat:@"%lu", idx+1]];
    }];
    
    [self gotoLabel:label forLineNumber:token.lineNumber];
}

- (void)handleReturnToken:(ReturnToken *)token {
    NSString *debug = @"return";
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
    
    GosubToken *last = [_gosubStack pop];
    _tokenIndex = last.stackIndex;
}

- (void)handleAssignmentToken:(AssignmentToken *)token {
    NSString *name = [token.left eval];
    NSString *val = [token.right eval];
    val = [self replaceVars:val];
    
    [self sendScriptDebug:[NSString stringWithFormat:@"setvariable %@ %@", name, val]
            forLineNumber:token.lineNumber];
    
    [_localVars setCacheObject:val forKey:name];
}

- (void)handleDebugLevelToken:(DebugLevelToken *)token {
    NSString *debug = [NSString stringWithFormat:@"debuglevel %@", [token eval]];
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
    
    NSNumber *level = [token eval];
    _debugLevel = [level integerValue];
}

- (void)handleSendToken:(SendToken *)token {
    NSString *val = [self replaceVars:[token eval]];
    NSString *debug = [NSString stringWithFormat:@"send %@", val];
    [self sendScriptDebug:debug forLineNumber:token.lineNumber];
}

- (void)waitForRoundtime:(waitActionBlock)wait {
    
    NSString *rtString = [_context.globalVars cacheObjectForKey:@"roundtime"];
    
    [self sendScriptDebug:[NSString stringWithFormat:@"Checking roundtime: %@", rtString] forLineNumber:0];
    
    if([rtString doubleValue] > 0) {
        
        [self sendScriptDebug:@"Waiting for roundtime" forLineNumber:0];
        
        __block BOOL gotSignal = NO;
        __block RACDisposable *signal = nil;
        
        signal = [_context.globalVars.changed subscribeNext:^(NSDictionary *changed) {
            
            if([[changed.allKeys firstObject] isEqualToString:@"roundtime"]) {
                
                double roundtime = [changed[@"roundtime"] doubleValue];
                
                NSLog(@"rt: %f", roundtime);
                
                if(roundtime <= 0) {
                    gotSignal = YES;
                    [_pauseCondition signal];
                    [signal dispose];
                    NSLog(@"rt done: %f", roundtime);
                }
            }
        }];
        
        [_pauseCondition lock];
        
        while(!gotSignal) {
            [_pauseCondition wait];
        }
        
        [_pauseCondition unlock];
        if(wait) {
            wait();
        }
    }
    else {
        if(wait) {
            wait();
        }
    }
}

- (void)sendCommand:(NSString *)command {
    
    CommandContext *ctx = [[CommandContext alloc] init];
    ctx.command = [command trimWhitespaceAndNewline];
    ctx.tag = [TextTag tagFor:[NSString stringWithFormat:@"[%@]: %@\n", _name, command] mono:YES];
    ctx.tag.color = @"#ACFF2F";
    
    [_commandRelay sendCommand:ctx];
}

- (void)sendEcho:(NSString *)echo {
    TextTag *tag = [TextTag tagFor:[NSString stringWithFormat:@"%@\n", [echo trimWhitespaceAndNewline]] mono:YES];
    tag.color = @"#00FFFF";
   
    [_commandRelay sendEcho:tag];
}

- (void)sendScriptDebug:(NSString *)msg forLineNumber:(NSUInteger)lineNumber {
    
    if(_debugLevel < 1) return;
    
    TextTag *tag = [TextTag tagFor:[NSString stringWithFormat:@"%@(%lu): %@\n", _name, (unsigned long)lineNumber, msg] mono:YES];
    tag.color = @"#0066CC";
    
    [_commandRelay sendEcho:tag];
}

- (NSString *)replaceVars:(NSString *)str {
    NSString *replaced = [_varReplacer replaceLocalArgumentVars:str withVars:_currentVars];
    replaced = [_varReplacer replace:replaced withContext:_context];
    return [_varReplacer replaceLocalVars:replaced withVars:_localVars];
}

@end
