//
//  ExpTrackerTester.m
//  Outlander
//
//  Created by Joseph McBride on 4/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "ExpTracker.h"

SPEC_BEGIN(ExpTrackerTester)

describe(@"ExpTracker", ^{
   
    __block ExpTracker *_tracker = nil;
    
    beforeEach(^{
        _tracker = [[ExpTracker alloc] init];
    });
    
    context(@"update", ^{
        
        it(@"should add new skill", ^{
            SkillExp *skill = [[SkillExp alloc] init];
            skill.name = @"Athletics";
            skill.ranks = [NSDecimalNumber decimalNumberWithString:@"55.5"];
            skill.mindState  = [LearningRate fromRate:3];
            skill.isNew = NO;
            
            [_tracker update:skill];
            
            [[[_tracker skills] should] haveCountOf:1];
        });
        
    });
    
    context(@"skillsWithExp]", ^{
        it(@"should only return new skills", ^{
            SkillExp *skill = [[SkillExp alloc] init];
            skill.name = @"Athletics";
            skill.ranks = [NSDecimalNumber decimalNumberWithString:@"55.5"];
            skill.mindState  = [LearningRate fromRate:0];
            skill.isNew = NO;
            [_tracker update:skill];
            
            skill = [[SkillExp alloc] init];
            skill.name = @"Locksmithing";
            skill.ranks = [NSDecimalNumber decimalNumberWithString:@"155.5"];
            skill.mindState  = [LearningRate fromRate:3];
            skill.isNew = YES;
            
            [_tracker update:skill];
            
            [[[_tracker skills] should] haveCountOf:2];
            [[[_tracker skillsWithExp] should] haveCountOf:1];
        });
    });
    
});

SPEC_END;