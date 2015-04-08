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
#import "Outlander-Swift.h"

SPEC_BEGIN(VariableReplacerTester)

describe(@"Variable Replacer", ^{
    
    __block VariableReplacer *_replacer;
    __block GameContext *_context;
    
    beforeEach(^{
        _replacer = [[VariableReplacer alloc] init];
        _context = [GameContext newInstance];
    });
    
    context(@"replace", ^{
        
        context(@"alias", ^{
            
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
            
            it(@"should replace alias within word boundry", ^{
                Alias *al = [[Alias alloc] init];
                al.pattern = @"l2";
                al.replace = @"load arrows";
                [_context.aliases addObject:al];
                
                NSString *result = [_replacer replace:@"do al2a l2" withContext:_context];
                
                [[result should] equal:@"do al2a load arrows"];
            });
        });
        
        context(@"global vars", ^{
            
            it(@"should replace global variable", ^{
                
                [_context.globalVars setCacheObject:@"longsword" forKey:@"lefthand"];
                
                NSString *result = [_replacer replace:@"$lefthand" withContext:_context];
                
                [[result should] equal:@"longsword"];
            });
            
            it(@"should replace multiple global variables within text", ^{
                
                [_context.globalVars setCacheObject:@"longsword" forKey:@"lefthand"];
                [_context.globalVars setCacheObject:@"backpack" forKey:@"primary.container"];
                
                NSString *result = [_replacer replace:@"stow my $lefthand in my $primary.container" withContext:_context];
                
                [[result should] equal:@"stow my longsword in my backpack"];
            });
            
            it(@"should handle unfound vars", ^{
                NSString *result = [_replacer replace:@"$does_not_exist" withContext:_context];
                
                [[result should] equal:@"$does_not_exist"];
            });
        });
        
        context(@"local vars", ^{
            
            __block TSMutableDictionary *_localVars;
            
            beforeEach(^{
                _localVars = [[TSMutableDictionary alloc] initWithName:@"localvars"];
            });
            
            
            it(@"should replace local variable", ^{
                
                [_localVars setCacheObject:@"longsword" forKey:@"lefthand"];
                
                NSString *result = [_replacer replaceLocalVars:@"%lefthand" withVars:_localVars];
                
                [[result should] equal:@"longsword"];
            });
            
            it(@"should replace multiple global variables within text", ^{
                
                [_localVars setCacheObject:@"longsword" forKey:@"lefthand"];
                [_localVars setCacheObject:@"backpack" forKey:@"primary.container"];
                
                NSString *result = [_replacer replaceLocalVars:@"stow my %lefthand in my %primary.container" withVars:_localVars];
                
                [[result should] equal:@"stow my longsword in my backpack"];
            });
            
            it(@"should handle unfound vars", ^{
                NSString *result = [_replacer replaceLocalVars:@"$does_not_exist" withVars:_localVars];
                
                [[result should] equal:@"$does_not_exist"];
            });
        });
        
        context(@"local argument vars", ^{
            
            __block TSMutableDictionary *_localVars;
            
            beforeEach(^{
                _localVars = [[TSMutableDictionary alloc] initWithName:@"argumentvars"];
            });
            
            
            it(@"should replace local variable", ^{
                
                [_localVars setCacheObject:@"longsword" forKey:@"0"];
                
                NSString *result = [_replacer replaceLocalArgumentVars:@"$0" withVars:_localVars];
                
                [[result should] equal:@"longsword"];
            });
            
            it(@"should replace multiple global variables within text", ^{
                
                [_localVars setCacheObject:@"longsword" forKey:@"1"];
                [_localVars setCacheObject:@"backpack" forKey:@"2"];
                
                NSString *result = [_replacer replaceLocalArgumentVars:@"stow my $1 in my $2" withVars:_localVars];
                
                [[result should] equal:@"stow my longsword in my backpack"];
            });
            
            it(@"should handle unfound vars", ^{
                NSString *result = [_replacer replaceLocalArgumentVars:@"$0" withVars:_localVars];
                
                [[result should] equal:@"$0"];
            });
        });
    });
});

SPEC_END
