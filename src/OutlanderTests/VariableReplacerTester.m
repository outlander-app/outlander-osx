//
//  VariableReplacerTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "VariableReplacer.h"
#import "Alias.h"

SPEC_BEGIN(VariableReplacerTester)

describe(@"Variable Replacer", ^{
    
    __block VariableReplacer *_replacer;
    __block GameContext *_context;
    
    beforeEach(^{
        _replacer = [[VariableReplacer alloc] init];
        _context = [[GameContext alloc] init];
    });
    
    context(@"replace", ^{
        
        it(@"should replace alias", ^{
            Alias *al = [[Alias alloc] init];
            al.pattern = @"l2";
            al.replace = @"load arrows";
            [_context.aliases addObject:al];
            
            NSString *result = [_replacer replace:@"l2" withContext:_context];
            
            [[result should] equal:@"load arrows"];
        });
        
        it(@"should replace alias within other text", ^{
            Alias *al = [[Alias alloc] init];
            al.pattern = @"l2";
            al.replace = @"load arrows";
            [_context.aliases addObject:al];
            
            NSString *result = [_replacer replace:@"do something l2 with something else" withContext:_context];
            
            [[result should] equal:@"do something load arrows with something else"];
        });
    });
});

SPEC_END
