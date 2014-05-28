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
    
    beforeEach(^{
        theHandler = [[VarCommandHandler alloc] init];
        theContext = [[GameContext alloc] init];
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
        });
    });
});

SPEC_END