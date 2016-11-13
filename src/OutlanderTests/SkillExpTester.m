//
//  SkillExpTester.m
//  Outlander
//
//  Created by Joseph McBride on 4/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "SkillExp.h"

QuickSpecBegin(SkillExpSpec)

describe(@"SkillExp", ^{
   
    context(@"description", ^{
        
        it(@"should display correctly", ^{
            SkillExp *exp = [[SkillExp alloc] init];
            exp.name = @"Locksmithing";
            exp.ranks = [NSDecimalNumber decimalNumberWithString:@"55.6"];
            exp.mindState = [LearningRate fromRate:3];
            
            expect(exp.description).to(equal(@"    Locksmithing:   55 60%   (3/34) +55.60"));
        });
        
        it(@"should replace underscore in name with space", ^{
            SkillExp *exp = [[SkillExp alloc] init];
            exp.name = @"Life_Magic";
            exp.ranks = [NSDecimalNumber decimalNumberWithString:@"155.23"];
            exp.mindState = [LearningRate fromRate:5];
            
            expect(exp.description).to(equal(@"      Life Magic:  155 23%   (5/34) +155.23"));
        });
        
        it(@"should display double-digit mind state correctly", ^{
            SkillExp *exp = [[SkillExp alloc] init];
            exp.name = @"Locksmithing";
            exp.ranks = [NSDecimalNumber decimalNumberWithString:@"55.6"];
            exp.mindState = [LearningRate fromRate:10];
            
            expect(exp.description).to(equal(@"    Locksmithing:   55 60%  (10/34) +55.60"));
        });
    });
});

QuickSpecEnd
