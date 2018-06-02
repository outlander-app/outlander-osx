//
//  VariableReplacer.m
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "VariableReplacer.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Alias.h"
#import "NSString+Categories.h"
#import "Outlander-Swift.h"
@import PEGKit;

@interface VariableReplacer() {
}
@end

@implementation VariableReplacer

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    return self;
}

- (NSString *)replace:(NSString *)data withContext:(GameContext *)context {
    VariableReplacer2 *replacer = [VariableReplacer2 newInstance];
    data = [replacer simplify:data :context.globalVarsCopy :@{} :@{} :@{} :@{}];
    data = [self replaceAlias:data withContext:context];
    return [replacer simplify:data :context.globalVarsCopy :@{} :@{} :@{} :@{}];
}

- (NSString *)replaceAlias:(NSString *)data withContext:(GameContext *)context {

    if([context.aliases count] == 0) {
        return data;
    }
    
    __block NSString *str = data;
    __block NSString *maybeAlias = data;

    NSRange range = [str rangeOfString:@" "];
    NSString *allArgs = @"";

    if(range.location != NSNotFound) {
        maybeAlias = [[str substringToIndex:range.location] trimWhitespace];
        allArgs = [str substringFromIndex:range.location + 1];
    }

    __block NSMutableArray *tokens = [[NSMutableArray alloc] init];

    PKTokenizer *tokenizer = [PKTokenizer tokenizerWithString:allArgs];
    [tokenizer enumerateTokensUsingBlock:^(PKToken *tok, BOOL *stop) {

        if(tok.tokenType != PKTokenTypeSymbol) {
            NSString *val = [[tok stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            [tokens addObject:val];
        }
    }];

    [tokens insertObject:allArgs atIndex:0];

    NSInteger maxArgCount = 10;

    if([tokens count] < maxArgCount) {
        NSInteger diff = maxArgCount - [tokens count];

        for (NSInteger i = 0; i < diff; i++) {
            [tokens addObject:@""];
        }
    }

    [context.aliases enumerateObjectsUsingBlock:^(Alias *obj, NSUInteger idx, BOOL *stop) {

        if(![maybeAlias isEqualToString:obj.pattern]) {
            return;
        }

        str = obj.replace;
        
        [tokens enumerateObjectsUsingBlock:^(NSString * _Nonnull token, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *key = [NSString stringWithFormat:@"$%lu", (unsigned long)idx];
            NSString *val = idx > 0 && [token containsString:@" "] ? [NSString stringWithFormat:@"\"%@\"", token] : token;
            str = [str stringByReplacingOccurrencesOfString: key
                                                 withString:val];
        }];
    }];
    
    return [str trimWhitespace];
}

@end
