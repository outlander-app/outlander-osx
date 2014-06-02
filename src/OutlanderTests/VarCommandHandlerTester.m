//
//  VarCommandHandlerTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "VarCommandHandler.h"
#import "GameContext.h"

SPEC_BEGIN(VarCommandHandlerTester)

describe(@"var command handler", ^{
   
    __block VarCommandHandler *theHandler = nil;
    __block GameContext *theContext = nil;
    __block NSInteger originalCount;
    
    beforeEach(^{
        theHandler = [[VarCommandHandler alloc] init];
        theContext = [[GameContext alloc] init];
        
        originalCount = theContext.globalVars.count;
    });
    
    context(@"can handle", ^{
        it(@"success", ^{
            BOOL result = [theHandler canHandle:@"#var one two"];
            [[theValue(result) should] equal:theValue(YES)];
        });
        
        it(@"failure", ^{
            BOOL result = [theHandler canHandle:@"var one two"];
            [[theValue(result) should] equal:theValue(NO)];
        });
    });
    
    context(@"handle", ^{
        it(@"sets global var", ^{
            [theHandler handle:@"#var one two" withContext:theContext];
            
            NSString *value = [theContext.globalVars cacheObjectForKey:@"one"];
            [[value should] equal:@"two"];
            [[theValue(theContext.globalVars.count) should] equal:theValue(originalCount + 1)];
        });
        
        it(@"sets global var", ^{
            [theHandler handle:@"#var one two three four" withContext:theContext];
            
            NSString *value = [theContext.globalVars cacheObjectForKey:@"one"];
            [[value should] equal:@"two three four"];
            [[theValue(theContext.globalVars.count) should] equal:theValue(originalCount + 1)];
        });
        
        it(@"updates existing global var", ^{
            [theHandler handle:@"#var one two" withContext:theContext];
            
            NSString *value = [theContext.globalVars cacheObjectForKey:@"one"];
            [[value should] equal:@"two"];
            [[theValue(theContext.globalVars.count) should] equal:theValue(originalCount + 1)];
            
            [theHandler handle:@"#var one three" withContext:theContext];
            
            value = [theContext.globalVars cacheObjectForKey:@"one"];
            [[value should] equal:@"three"];
            
            [[theValue(theContext.globalVars.count) should] equal:theValue(originalCount + 1)];
        });
    });
});

SPEC_END