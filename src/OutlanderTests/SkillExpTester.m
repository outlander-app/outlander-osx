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
            
            [[exp.description should] equal:@"    Locksmithing:   55 60%  3/34"];
        });
        
    });
});

SPEC_END