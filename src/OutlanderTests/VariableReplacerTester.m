//
//  VariableReplacerTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "VariableReplacer.h"
#import "Alias.h"
#import "Outlander-Swift.h"

QuickSpecBegin(VariableReplacerSpec)

describe(@"Variable Replacer", ^{
    
    __block VariableReplacer *_replacer;
    __block GameContext *_context;
    
    beforeEach(^{
        _replacer = [[VariableReplacer alloc] init];
        _context = [GameContext newInstance];
    });
    
    context(@"replace", ^{
        
        context(@"alias", ^{

            it(@"should be able to use punctuation as an alias", ^{
                Alias *al = [[Alias alloc] init];
                al.pattern = @"=";
                al.replace = @"#send $0";
                [_context.aliases addObject:al];
                
                NSString *result = [_replacer replace:@"= one two" withContext:_context];

                expect(result).to(equal(@"#send one two"));
            });

            it(@"should be able to include semicolons", ^{
                Alias *al = [[Alias alloc] init];
                al.pattern = @"-bund";
                al.replace = @"remove my bundle;sell my bundle;stow my rope";
                [_context.aliases addObject:al];
                
                NSString *result = [_replacer replace:@"-bund" withContext:_context];

                expect(result).to(equal(@"remove my bundle;sell my bundle;stow my rope"));
            });
            
            it(@"should replace alias", ^{
                Alias *al = [[Alias alloc] init];
                al.pattern = @"l2";
                al.replace = @"load arrows";
                [_context.aliases addObject:al];
                
                NSString *result = [_replacer replace:@"l2" withContext:_context];

                expect(result).to(equal(@"load arrows"));
            });
            
            it(@"should replace alias variables", ^{
                Alias *al = [[Alias alloc] init];
                al.pattern = @"fire";
                al.replace = @"snipe $0";
                [_context.aliases addObject:al];
                
                NSString *result = [_replacer replace:@"fire one two" withContext:_context];

                expect(result).to(equal(@"snipe one two"));
            });
            
            it(@"should replace alias variables 2", ^{
                Alias *al = [[Alias alloc] init];
                al.pattern = @"fire";
                al.replace = @"aim $1;snipe $2;look $3";
                [_context.aliases addObject:al];
                
                NSString *result = [_replacer replace:@"fire one \"two three\" four" withContext:_context];
                
                expect(result).to(equal(@"aim one;snipe \"two three\";look four"));
            });
            
            it(@"should replace alias variables 3", ^{
                Alias *al = [[Alias alloc] init];
                al.pattern = @"fire";
                al.replace = @"aim $1;snipe $2";
                [_context.aliases addObject:al];
                
                NSString *result = [_replacer replace:@"fire one two" withContext:_context];

                expect(result).to(equal(@"aim one;snipe two"));
            });
            
            it(@"should not match partial", ^{
                Alias *al = [[Alias alloc] init];
                al.pattern = @"fir";
                al.replace = @"aim $1;snipe $2";
                [_context.aliases addObject:al];
                
                NSString *result = [_replacer replace:@"fire one two" withContext:_context];

                expect(result).to(equal(@"fire one two"));
            });
        });

    });
});

QuickSpecEnd
