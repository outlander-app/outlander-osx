//
//  SkillExpTester.m
//  Outlander
//
//  Created by Joseph McBride on 4/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "SkillExp.h"

SPEC_BEGIN(SkillExpTester)

describe(@"SkillExp", ^{
   
    context(@"description", ^{
        
        it(@"should display correctly", ^{
            SkillExp *exp = [[SkillExp alloc] init];
            exp.name = @"Locksmithing";
            exp.ranks = [NSDecimalNumber decimalNumberWithString:@"55.6"];
            exp.mindState = [LearningRate fromRate:3];
            
            [[exp.description should] equal:@"    Locksmithing:   55 60%   (3/34)"];
        });
        
        it(@"should replace underscore in name with space", ^{
            SkillExp *exp = [[SkillExp alloc] init];
            exp.name = @"Life_Magic";
            exp.ranks = [NSDecimalNumber decimalNumberWithString:@"155.23"];
            exp.mindState = [LearningRate fromRate:5];
            
            [[exp.description should] equal:@"      Life Magic:  155 23%   (5/34)"];
        });
        
        it(@"should display double-digit mind state correctly", ^{
            SkillExp *exp = [[SkillExp alloc] init];
            exp.name = @"Locksmithing";
            exp.ranks = [NSDecimalNumber decimalNumberWithString:@"55.6"];
            exp.mindState = [LearningRate fromRate:10];
            
            [[exp.description should] equal:@"    Locksmithing:   55 60%  (10/34)"];
        });
    });
});

SPEC_END