//
//  ScriptTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/28/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "Script.h"
#import "GameContext.h"
#import "StubCommandRelay.h"
#import "StubInfoStream.h"

SPEC_BEGIN(ScriptTester)

describe(@"Script", ^{
    
    __block Script *theScript = nil;
    __block GameContext *theContext = nil;
    __block StubCommandRelay *theRelay = nil;
    __block StubInfoStream *theInfoStream = nil;
    
    beforeEach(^{
        theContext = [[GameContext alloc] init];
        theScript = [[Script alloc] initWith:theContext and:@""];
        theRelay = [[StubCommandRelay alloc] init];
        theInfoStream = [[StubInfoStream alloc] init];
      
        theScript.name = @"test";
        [theScript setGameStream:theInfoStream];
        [theScript setCommandRelay:theRelay];
    });
    
    context(@"vars", ^{
       
        it(@"set local var", ^{
            
            NSString *sample = @"var one two";
            
            [theScript setData:sample];
            
            [theScript process];
            
            NSString *one = [theScript.localVars cacheObjectForKey:@"one"];
            
            [[one should] equal:@"two"];
        });
        
        it(@"use local var", ^{
            NSString *sample = @"put %one";
            
            [theScript.localVars setCacheObject:@"two" forKey:@"one"];
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastCommand.command should] equal:@"two"];
        });
        
        it(@"use numbered local var", ^{
            NSString *sample = @"put %1";
            
            [theScript.localVars setCacheObject:@"one" forKey:@"1"];
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastCommand.command should] equal:@"one"];
        });
        
        it(@"use numbered local var", ^{
            NSString *sample = @"put %12";
            
            [theScript.localVars setCacheObject:@"one two three" forKey:@"12"];
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastCommand.command should] equal:@"one two three"];
        });
        
        it(@"use global var", ^{
            NSString *sample = @"put $backpack";
            
            [theContext.globalVars setCacheObject:@"some value" forKey:@"backpack"];
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastCommand.command should] equal:@"some value"];
        });
        
        it(@"use global var within sentence", ^{
            NSString *sample = @"put put my $righthand in my $backpack";
            
            [theContext.globalVars setCacheObject:@"longsword" forKey:@"righthand"];
            [theContext.globalVars setCacheObject:@"rucksack" forKey:@"backpack"];
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastCommand.command should] equal:@"put my longsword in my rucksack"];
        });
        
        it(@"use global var with dot syntax", ^{
            NSString *sample = @"put put my $righthand in my $primary.container";
            
            [theContext.globalVars setCacheObject:@"longsword" forKey:@"righthand"];
            [theContext.globalVars setCacheObject:@"rucksack" forKey:@"primary.container"];
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastCommand.command should] equal:@"put my longsword in my rucksack"];
        });
    });
    
    context(@"commands", ^{
       
        it(@"send echo", ^{
            
            NSString *sample = @"echo one two";
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastEcho.text should] equal:@"[test]: one two\n"];
        });
        
        it(@"send empty echo", ^{
            
            NSString *sample = @"echo";
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastEcho.text should] equal:@"[test]: \n"];
        });
    });
    
    context(@"commands", ^{
       
        it(@"send pause script command", ^{
            
            NSString *sample = @"#script pause two";
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastCommand.command should] equal:@"#script pause two"];
        });
        
        it(@"send abort script command", ^{
            
            NSString *sample = @"#script abort one";
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastCommand.command should] equal:@"#script abort one"];
        });
        
        it(@"send resume script command", ^{
            
            NSString *sample = @"#script resume one";
            
            [theScript setData:sample];
            
            [theScript process];
            
            [[theRelay.lastCommand.command should] equal:@"#script resume one"];
        });
    });
    
    context(@"move commands", ^{
        it(@"send move command", ^{
            
            NSString *sample = @"move ne";
            
            [theScript setData:sample];
            
            [theScript start];
            
            [theInfoStream publishRoom];
            
            [[expectFutureValue(theRelay.lastCommand.command) shouldEventually] equal:@"ne"];
        });
        
        it(@"send nextroom command", ^{
            
            NSString *sample = @"nextroom ne";
            
            [theScript setData:sample];
            
            [theScript start];
            
            [theInfoStream publishRoom];
            
            [[expectFutureValue(theRelay.lastEcho.text) shouldEventually] equal:@"[test (0)]: nextroom - waiting for room description\n"];
        });
    });
    
    context(@"wait commands", ^{
        
        // not really testing anything -- how to test for wait?
        xit(@"waits for command prompt", ^{
            
            NSString *sample = @"wait";
            
            [theScript setData:sample];
            
            [theScript start];
            
            [theInfoStream publishSubject:@">"];
            
            [[expectFutureValue(theInfoStream.lastSubject) shouldEventually] equal:@">"];
        });
        
        // not really testing anything -- how to test for wait?
        xit(@"waitfor - wait for text", ^{
            
            NSString *sample = @"waitfor something";
            
            [theScript setData:sample];
            
            [theScript start];
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject:[TextTag tagFor:@"something" mono:NO]];
            
            [theInfoStream publishSubject:arr];
            
            [[expectFutureValue(theRelay.lastEcho.text) shouldEventuallyBeforeTimingOutAfter(2.0)] equal:@"matched"];
        });
        
        // not really testing anything -- how to test for wait?
        xit(@"waitforre - wait for text", ^{
            
            NSString *sample = @"waitforre something|or another";
            
            [theScript setData:sample];
            
            [theScript start];
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject:[TextTag tagFor:@"something" mono:NO]];
            
            [theInfoStream publishSubject:arr];
            
            [[expectFutureValue(theRelay.lastEcho.text) shouldEventuallyBeforeTimingOutAfter(2.0)] equal:@"matched"];
        });
    });
});

SPEC_END
