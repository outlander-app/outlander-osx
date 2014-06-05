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
            NSArray *a = [_builder build:@"put one $two"];
            
            PutToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"one $two"];
        });
        
        it(@"put", ^{
            NSArray *a = [_builder build:@"put %one_two $two"];
            
            PutToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"%one_two $two"];
        });
        
        xit(@"put", ^{
            NSArray *a = [_builder build:@"put %one_two $two \n something"];
            
            PutToken *put = [a firstObject];
            
            [[[put eval] should] equal:@"%one_two $two"];
        });
    });
    
    context(@"misc", ^{
      
        it(@"creates label", ^{
            NSArray *a = [_builder build:@"one.two:"];
            LabelToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"one.two"];
        });
        
        it(@"creates label", ^{
            NSArray *a = [_builder build:@"one_two:"];
            LabelToken *var = [a firstObject];
            
            [[[var eval] should] equal:@"one_two"];
        });
    });
});

SPEC_END