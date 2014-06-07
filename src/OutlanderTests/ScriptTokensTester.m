//
//  ScriptTokensTester.m
//  Outlander
//
//  Created by Joseph McBride on 6/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//


#import "Kiwi.h"
#import "Script.h"
#import "GameContext.h"
#import "StubCommandRelay.h"
#import "StubInfoStream.h"
#import "ExpressionBuilder.h"

SPEC_BEGIN(ScriptTokensTester)

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
            NSString *sample = @"var one two\necho %one";
            [theScript setData:sample];
            
            [[theScript.syntaxTree should] haveCountOf:2];
            
            AssignmentToken *token1 = [theScript.syntaxTree firstObject];
            [[token1 should] beNonNil];
            [[[token1.left eval] should] equal:@"one"];
            [[[token1.right eval] should] equal:@"two"];
            
            EchoToken *token2 = [theScript.syntaxTree lastObject];
            [[token2 should] beNonNil];
            [[[token2 eval] should] equal:@"%one"];
        });
    });
    
    context(@"matches", ^{
        it(@"creates match token", ^{
            NSString *sample = @"match one two\nmatch three four\nmatchwait 10";
            [theScript setData:sample];

            [[theScript.syntaxTree should] haveCountOf:1];
            
            MatchWaitToken *token = [theScript.syntaxTree firstObject];
            [[token should] beNonNil];
            [[token.tokens should] haveCountOf:2];
            [[token.waitTime should] equal:@(10)];
        });
        
        it(@"creates match token", ^{
            NSString *sample = @"match one two\nmatchre three four|five\nmatchwait";
            [theScript setData:sample];

            [[theScript.syntaxTree should] haveCountOf:1];
            
            MatchWaitToken *token = [theScript.syntaxTree firstObject];
            [[token should] beNonNil];
            [[token.tokens should] haveCountOf:2];
            [[token.waitTime should] beNil];
            
            MatchToken *match = [token.tokens lastObject];
            [[[match.left eval] should] equal:@"three"];
            [[[match.right eval] should] equal:@"four|five"];
        });
    });
    
    context(@"labels & goto", ^{
        it(@"tokens", ^{
            NSString *sample = @"start:\necho hello\npause 3\ngoto start";
            [theScript setData:sample];

            [[theScript.syntaxTree should] haveCountOf:4];
            
            LabelToken *label = [theScript.syntaxTree firstObject];
            [[label should] beNonNil];
            [[[label eval] should] equal:@"start"];
            
            EchoToken *echo = [theScript.syntaxTree objectAtIndex:1];
            [[echo should] beNonNil];
            [[[echo eval] should] equal:@"hello"];
            
            PauseToken *pause = [theScript.syntaxTree objectAtIndex:2];
            [[pause should] beNonNil];
            
            GotoToken *gotoToken = [theScript.syntaxTree lastObject];
            [[gotoToken should] beNonNil];
            [[[gotoToken eval] should] equal:@"start"];
        });
    });
});

SPEC_END
