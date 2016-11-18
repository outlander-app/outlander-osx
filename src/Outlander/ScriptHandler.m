//
//  ScriptHandler.m
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ScriptHandler.h"
@import PEGKit;

@interface ScriptHandler () {
    id<EventRelay> _relay;
}
@end

@implementation ScriptHandler

- (instancetype)initWith:(id<EventRelay>)relay {
    self = [super init];
    if(!self) return nil;
    
    _relay = relay;
    
    return self;
}

- (BOOL)canHandle:(NSString *)command {
    return [command hasPrefix:@"."];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    
    __block NSMutableArray *tokens = [[NSMutableArray alloc] init];
    
    NSRange range = [command rangeOfString:@" "];
    NSString *allArgs = @"";
    
    if(range.location != NSNotFound) {
        allArgs = [command substringFromIndex:range.location + 1];
    }
    
    PKTokenizer *tokenizer = [PKTokenizer tokenizerWithString:command];
    [tokenizer enumerateTokensUsingBlock:^(PKToken *tok, BOOL *stop) {
       
        if(tok.tokenType != PKTokenTypeSymbol) {
            NSString *val = [[tok stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            [tokens addObject:val];
        }
    }];
    
    NSString *target = tokens[0];
    [tokens removeObjectAtIndex:0];
    
    NSDictionary *userInfo = @{@"target": target, @"args": tokens, @"allArgs": allArgs};
    [_relay send:@"startscript" with:userInfo];
}
@end
