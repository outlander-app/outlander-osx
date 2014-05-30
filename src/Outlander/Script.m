//
//  Script.m
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Script.h"
#import "TSMutableDictionary.h"
#import <PEGKit/PEGKit.h>
#import "OutlanderParser.h"
#import "TextTag.h"
#import "CommandContext.h"
#import "CommandHandler.h"

@interface Script () {
    id<InfoStream> _gameStream;
    GameContext *_context;
    OutlanderParser *_parser;
    NSMutableArray *_scriptLines;
}

@property (nonatomic, strong) TSMutableDictionary *labels;
@property (nonatomic, assign) NSUInteger lineNumber;

@end

@implementation Script

- (instancetype)initWith:(GameContext *)context and:(NSString *)data {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    
    _labels = [[TSMutableDictionary alloc] initWithName:[NSString stringWithFormat:@"com.outlander.script.labels.%@", self.uuid]];
    _localVars = [[TSMutableDictionary alloc] initWithName:[NSString stringWithFormat:@"com.outlander.script.localvars.%@", self.uuid]];
    
    _parser = [[OutlanderParser alloc] initWithDelegate:self];
    
    _lineNumber = 0;
    
    NSArray *lines = [data componentsSeparatedByString:@"\n"];
    
    _scriptLines = [[NSMutableArray alloc] initWithArray:lines];
    
    return self;
}

- (void)setGameStream:(id<InfoStream>)stream {
    _gameStream = stream;
}

- (void)process {
    NSLog(@"%@ :: script running", [self description]);
    
    if(_lineNumber >= _scriptLines.count) {
        NSLog(@"End of script!");
        [self cancel];
        return;
    }
    
    NSString *line = _scriptLines[_lineNumber];
   
    NSError *err;
    PKAssembly *result = [_parser parseString:line error:&err];
    
    if(err) {
        NSLog(@"err: %@", [err localizedDescription]);
        [self cancel];
        return;
    }
    
    NSLog(@"Script line result: %@", [result description]);
    
    _lineNumber++;
}

- (void)parser:(PKParser *)p didMatchMoveStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
   
    __block BOOL gotRoom = NO;
    __block RACDisposable *signal = nil;
    
    signal = [_gameStream.room.signal subscribeNext:^(id x) {
        gotRoom = YES;
        [signal dispose];
    }];

    NSString *moveString = [self popCommandsToString:a];
    [self sendCommand:moveString];
    
    while(!gotRoom) {
    }
}

- (void)parser:(PKParser *)p didMatchCommandsStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    NSMutableString *commandString = [self popCommandsToString:a];
    
    [commandString insertString:@"#" atIndex:0];
    [self sendCommand:commandString];
}

- (void)parser:(PKParser *)p didMatchVarStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *rh = [a pop];
    PKToken *lh = [a pop];
    
    [self.localVars setCacheObject:[rh stringValue] forKey:[lh stringValue]];
}

- (void)parser:(PKParser *)p didMatchPutStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    NSString *putString = [self popCommandsToString:a];
    
    NSLog(@"putting: %@", putString);
    
    [self sendCommand:putString];
}

- (void)parser:(PKParser *)p didMatchPauseStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *token = [a pop];
    
    // ignore pause in #script statements
    if([[token stringValue] isEqualToString:@"script"])
        return;
    
    NSTimeInterval interval = 1.0;
    if(token) {
        interval = [token doubleValue];
        if(interval < 1) {
            interval = 1.0;
        }
    }
    
    NSString *debug = [NSString stringWithFormat:@"pausing for %#2.0f", interval];
    [self sendScriptDebug:debug];
    
    [NSThread sleepForTimeInterval:interval];
}

- (void)parser:(PKParser *)p didMatchLabelStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *label = [a pop];
    
    NSLog(@"Label: %@", [label stringValue]);
    
    [_labels setCacheObject:@(_lineNumber) forKey:[label stringValue]];
}

- (void)parser:(PKParser *)p didMatchGotoStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *label = [a pop];
    
    NSLog(@"goto: %@", [label stringValue]);
    
    NSNumber *gotoObj = [_labels cacheObjectForKey:[label stringValue]];
    
    if(!gotoObj) {
        NSLog(@"Unknown label %@", [label stringValue]);
        [self cancel];
        return;
    }
    
    _lineNumber = [gotoObj integerValue];
}

- (void)sendCommand:(NSString *)command {
    
    CommandContext *ctx = [[CommandContext alloc] init];
    ctx.command = command;
    ctx.tag = [TextTag tagFor:[NSString stringWithFormat:@"[%@]: %@\n", _name, command] mono:YES];
    ctx.tag.color = @"#0066CC";
    
    NSDictionary *userInfo = @{@"command": ctx};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"command"
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)sendEcho:(NSString *)echo {
    TextTag *tag = [TextTag tagFor:[NSString stringWithFormat:@"[%@]: %@\n", _name, echo] mono:YES];
    tag.color = @"#0066CC";
    
    NSDictionary *userInfo = @{@"tag": tag};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"echo"
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)sendScriptDebug:(NSString *)msg {
    TextTag *tag = [TextTag tagFor:[NSString stringWithFormat:@"[%@]: %@\n", _name, msg] mono:YES];
    tag.color = @"#0066CC";
    
    NSDictionary *userInfo = @{@"tag": tag};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"echo"
                                                        object:nil
                                                      userInfo:userInfo];
}

- (NSMutableString *)popCommandsToString:(PKAssembly *)a {
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    PKToken *token = [a pop];
    
    while(token) {
        
        [str insertString:[NSString stringWithFormat:@"%@ ", [token stringValue]]
                        atIndex:0];
        
        token = [a pop];
    }
    
    return str;
}

@end
