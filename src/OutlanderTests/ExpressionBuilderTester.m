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
});

SPEC_END