//
//  ExpressionParserTester.m
//  Outlander
//
//  Created by Joseph McBride on 6/4/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "ExpressionBuilder.h"
#import "VarToken.h"

SPEC_BEGIN(ExpressionBuilderTester)

describe(@"ExpressionBuilder", ^{
   
    __block ExpressionBuilder *_builder = nil;
    
    beforeEach(^{
        _builder = [[ExpressionBuilder alloc] init];
    });
    
    context(@"vars", ^{
        
        it(@"creates local var assignment", ^{
            
            NSArray *a = [_builder build:@"var one two"];
            AssignmentToken *token = [a firstObject];
            
            [[[token.right eval] should] equal:@"two"];
            [[[token.left eval] should] equal:@"one"];
        });
        
        it(@"creates global var assignment", ^{
            
            NSArray *a = [_builder build:@"var one.three $two"];
            AssignmentToken *token = [a firstObject];
            
            [[[token.right eval] should] equal:@"$two"];
            [[[token.left eval] should] equal:@"one.three"];
        });
        
        it(@"creates local var assignment", ^{
            
            NSArray *a = [_builder build:@"var one.three %two.1"];
            AssignmentToken *token = [a firstObject];
            
            [[[token.right eval] should] equal:@"%two.1"];
            [[[token.left eval] should] equal:@"one.three"];
        });
        
        it(@"creates argument var assignment", ^{
            
            NSArray *a = [_builder build:@"var one.three %19"];
            AssignmentToken *token = [a firstObject];
            
            [[[token.right eval] should] equal:@"%19"];
            [[[token.left eval] should] equal:@"one.three"];
        });
        
        it(@"creates multi var assignment", ^{
            
            NSArray *a = [_builder build:@"var one.three %19;setvariable four five"];
            
            AssignmentToken *token = [a firstObject];
            [[[token.right eval] should] equal:@"%19"];
            [[[token.left eval] should] equal:@"one.three"];
            
            token = [a lastObject];
            [[[token.right eval] should] equal:@"five"];
            [[[token.left eval] should] equal:@"four"];
        });
    });
    
    context(@"put", ^{
        
        it(@"simple put", ^{
            NSArray *a = [_builder build:@"put one"];
            
            PutToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"one"];
        });
      
        it(@"simple put", ^{
            NSArray *a = [_builder build:@"put one $two"];
            
            PutToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"one $two"];
        });
        
        it(@"put", ^{
            NSArray *a = [_builder build:@"put %one_two $two\n"];
            
            PutToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"%one_two $two"];
        });
        
        xit(@"put", ^{
            NSArray *a = [_builder build:@"put %one_two $two \n something"];
            
            PutToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"%one_two $two"];
        });
    });
    
    context(@"label", ^{
      
        it(@"creates label", ^{
            NSArray *a = [_builder build:@"one.two:\n"];
            LabelToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"one.two"];
        });
        
        it(@"creates label", ^{
            NSArray *a = [_builder build:@"one_two:"];
            LabelToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"one_two"];
        });
    });
    
    context(@"pause", ^{
      
        it(@"creates with default", ^{
            NSArray *a = [_builder build:@"pause"];
            PauseToken *var = [a firstObject];
            
            [[[var eval] should] equal:[NSNumber numberWithDouble:1.0]];
        });
        
        it(@"creates with number", ^{
            NSArray *a = [_builder build:@"pause 3"];
            PauseToken *var = [a firstObject];
            
            [[[var eval] should] equal:[NSNumber numberWithDouble:3.0]];
        });
    });

    context(@"echo", ^{
        
        it(@"simple", ^{
            NSArray *a = [_builder build:@"echo one"];
            
            EchoToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"one"];
        });
        
        it(@"blank", ^{
            NSArray *a = [_builder build:@"echo"];
            
            EchoToken *put = [a firstObject];
            
            [[[put eval] should] equal:@""];
        });
      
        it(@"mix vars and text", ^{
            NSArray *a = [_builder build:@"echo one $two"];
            
            EchoToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"one $two"];
        });
        
        it(@"with vars", ^{
            NSArray *a = [_builder build:@"echo %one_two $two\n"];
            
            EchoToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"%one_two $two"];
        });
    });
    
    context(@"goto", ^{
      
        it(@"creates goto", ^{
            NSArray *a = [_builder build:@"goto one.two\n"];
            GotoToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"one.two"];
        });
        
        it(@"creates goto", ^{
            NSArray *a = [_builder build:@"goto one_two"];
            GotoToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"one_two"];
        });
        
        it(@"creates goto", ^{
            NSArray *a = [_builder build:@"goto $one_two"];
            GotoToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"$one_two"];
        });
    });
    
    context(@"move", ^{
      
        it(@"creates move", ^{
            NSArray *a = [_builder build:@"move one.two\n"];
            MoveToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"one.two"];
        });
        
        it(@"with global var", ^{
            NSArray *a = [_builder build:@"move $one_two"];
            MoveToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"$one_two"];
        });
        
        it(@"with local var", ^{
            NSArray *a = [_builder build:@"move %one_two"];
            MoveToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"%one_two"];
        });
        
        it(@"with argument var", ^{
            NSArray *a = [_builder build:@"move %1"];
            MoveToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"%1"];
        });
    });
    
    context(@"wait", ^{
        
        it(@"simple waitfor", ^{
            NSArray *a = [_builder build:@"waitfor one"];
            
            WaitToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"one"];
        });
      
        it(@"simple waitfor", ^{
            NSArray *a = [_builder build:@"waitfor one $two"];
            
            WaitToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"one $two"];
        });
        
        it(@"waitfor", ^{
            NSArray *a = [_builder build:@"waitfor %one_two $two\n"];
            
            WaitToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"%one_two $two"];
        });
        
        xit(@"waitfor", ^{
            NSArray *a = [_builder build:@"waitfor %one_two $two \n something"];
            
            PutToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"%one_two $two"];
        });
        
        it(@"simple waitforre", ^{
            NSArray *a = [_builder build:@"waitforre one"];
            
            WaitToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"one"];
        });
      
        it(@"simple waitforre", ^{
            NSArray *a = [_builder build:@"waitforre one $two"];
            
            WaitToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"one $two"];
        });
        
        it(@"waitforre", ^{
            NSArray *a = [_builder build:@"waitforre %one_two $two\n"];
            
            WaitToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"%one_two $two"];
        });
        
        xit(@"waitforre", ^{
            NSArray *a = [_builder build:@"waitforre %one_two $two \n something"];
            
            PutToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"%one_two $two"];
        });
    });
    
    context(@"match", ^{
        it(@"creates match", ^{
            [_builder build:@"match label some text"];
            
            MatchToken *match = [[_builder matchTokens] firstObject];
            [[[match.left eval] should] equal:@"label"];
            [[[match.right eval] should] equal:@"some text"];
        });
        
        it(@"creates matchre", ^{
            [_builder build:@"matchre label some|text"];
            
            MatchToken *match = [[_builder matchTokens] firstObject];
            [[[match.left eval] should] equal:@"label"];
            [[[match.right eval] should] equal:@"some|text"];
        });
        
        it(@"creates matchre", ^{
            [_builder build:@"matchre label \\w"];
            
            MatchToken *match = [[_builder matchTokens] firstObject];
            [[[match.left eval] should] equal:@"label"];
            [[[match.right eval] should] equal:@"some|text"];
        });
        
        it(@"creates matchwait", ^{
            NSArray *a = [_builder build:@"matchwait"];
            
            MatchWaitToken *matches = [a firstObject];
            [[matches should] beNonNil];
        });
        
        it(@"creates matchwait", ^{
            NSArray *a = [_builder build:@"matchwait 10"];
            
            MatchWaitToken *matches = [a firstObject];
            [[matches.waitTime should] equal:@(10)];
        });
        
        it(@"creates matchwait with match tokens", ^{
            [_builder build:@"match label1 some text"];
            [_builder build:@"match label2 some other text"];
            
            [[[_builder matchTokens] should] haveCountOf:2];
            
            NSArray *a = [_builder build:@"matchwait 10"];
            
            MatchWaitToken *matches = [a firstObject];
            [[matches.waitTime should] equal:@(10)];
            [[matches.tokens should] haveCountOf:2];
            
            [[[_builder matchTokens] should] haveCountOf:0];
        });
    });
    
    context(@"exit", ^{
        it(@"creates exit token", ^{
            NSArray *a = [_builder build:@"exit"];
            
            ExitToken *tok = [a firstObject];
            [[tok should] beNonNil];
        });
    });
    
    context(@"nextroom", ^{
        it(@"creates nextroom token", ^{
            NSArray *a = [_builder build:@"nextroom"];
            
            NextRoomToken *tok = [a firstObject];
            [[tok should] beNonNil];
        });
    });
});

SPEC_END