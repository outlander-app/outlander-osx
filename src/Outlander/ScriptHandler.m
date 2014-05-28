//
//  ScriptHandler.m
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ScriptHandler.h"
#import <PEGKit/PEGKit.h>

@implementation ScriptHandler

- (BOOL)canHandle:(NSString *)command {
    return [command hasPrefix:@"."];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    
    __block NSMutableArray *tokens = [[NSMutableArray alloc] init];
    
    PKTokenizer *tokenizer = [PKTokenizer tokenizerWithString:command];
    [tokenizer enumerateTokensUsingBlock:^(PKToken *tok, BOOL *stop) {
       
        NSLog(@"%@", tok);
        
        if(tok.tokenType != PKTokenTypeSymbol) {
            [tokens addObject:[tok stringValue]];
        }
    }];
    
    NSString *target = tokens[0];
    [tokens removeObjectAtIndex:0];
    
    NSDictionary *userInfo = @{@"target": target, @"args": tokens};
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"startscript"
                      object:self
                    userInfo:userInfo];
}
@end
