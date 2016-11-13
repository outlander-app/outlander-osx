//
//  ExpTrackerTester.m
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

#import "ExpTracker.h"

QuickSpecBegin(ExpTrackerSpec)

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

            expect(@(_tracker.skills.count)).to(equal(@1));
        });
        
        it(@"should handle nils", ^{
            [_tracker update:nil];

            expect(@(_tracker.skills.count)).to(equal(@0));
        });
        
        
        it(@"should update existing skill", ^{
            
            SkillExp *skill = [[SkillExp alloc] init];
            skill.name = @"Athletics";
            skill.ranks = [NSDecimalNumber decimalNumberWithString:@"55.5"];
            skill.mindState  = [LearningRate fromRate:3];
            skill.isNew = YES;
            [_tracker update:skill];
            
            skill = [[SkillExp alloc] init];
            skill.name = @"Athletics";
            skill.ranks = [NSDecimalNumber decimalNumberWithString:@"0"];
            skill.mindState  = [LearningRate fromRate:0];
            skill.isNew = NO;
            
            [_tracker update:skill];
            expect(@(_tracker.skills.count)).to(equal(@1));
            
            SkillExp *exp = [[_tracker skills] firstObject];
            expect(exp.ranks).to(equal(@55.5));
        });
    });
    
    context(@"skillsWithExp", ^{
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

            expect(@(_tracker.skills.count)).to(equal(@2));
            expect(@(_tracker.skillsWithExp.count)).to(equal(@1));
        });
    });
    
});

QuickSpecEnd