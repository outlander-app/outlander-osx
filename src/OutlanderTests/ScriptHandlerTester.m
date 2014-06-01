//
//  ScriptHandlerTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/31/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "ScriptHandler.h"
#import "Script.h"
#import "GameContext.h"
#import "StubEventRelay.h"

SPEC_BEGIN(ScriptHandlerTester)

describe(@"Script Runner", ^{
    
    __block ScriptHandler *theHandler = nil;
    __block GameContext *theContext = nil;
    __block StubEventRelay *theEventRelay = nil;
    
    beforeEach(^{
        theContext = [[GameContext alloc] init];
        theEventRelay = [[StubEventRelay alloc] init];
        theHandler = [[ScriptHandler alloc] initWith:theEventRelay];
    });
    
    context(@"arguments", ^{
        it(@"sets arguments", ^{
            
            [theHandler handle:@".script one two" withContext:theContext];
            
            [[theEventRelay.lastEvent should] equal:@"startscript"];
            [[theEventRelay.lastEventData[@"allArgs"] should] equal:@"one two"];
           
            NSArray *args = theEventRelay.lastEventData[@"args"];
            
            [[args[0] should] equal:@"one"];
            [[args[1] should] equal:@"two"];
        });
        
        it(@"handles no arguments", ^{
            
            [theHandler handle:@".script" withContext:theContext];
            
            [[theEventRelay.lastEvent should] equal:@"startscript"];
            [[theEventRelay.lastEventData[@"allArgs"] should] equal:@""];
           
            NSArray *args = theEventRelay.lastEventData[@"args"];
            [[args should] haveCountOf:0];
        });
        
        it(@"handles quoted arguments", ^{
            
            [theHandler handle:@".script one \"two three\"" withContext:theContext];
            
            [[theEventRelay.lastEvent should] equal:@"startscript"];
            [[theEventRelay.lastEventData[@"allArgs"] should] equal:@"one \"two three\""];
           
            NSArray *args = theEventRelay.lastEventData[@"args"];
            
            [[args[0] should] equal:@"one"];
            [[args[1] should] equal:@"two three"];
        });
    });
});

SPEC_END
