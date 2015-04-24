//
//  SkillExp.m
//  Outlander
//
//  Created by Joseph McBride on 4/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SkillExp.h"

@implementation SkillExp

- (instancetype)init {
    self = [super init];
    if (self) {
        _ranks = [NSDecimalNumber decimalNumberWithString:@"0"];
        _originalRanks = [NSDecimalNumber decimalNumberWithString:@"0"];
        _mindState = [LearningRate fromRate:0];
    }
    return self;
}

- (NSString *)description {
    NSString *mindstate = [NSString stringWithFormat:@"(%@/34)", @(self.mindState.rateId)];
    double diff = _ranks.doubleValue - _originalRanks.doubleValue;
    NSString *sign = diff > 0 ? @"+" : @"-";
    if (diff == 0.0) {
        sign = @" ";
    }
    NSString *diffStr = [NSString stringWithFormat:@"%@%0.2f", sign, diff];
    return [NSString stringWithFormat:@"%16s: %4d %02.0f%%  %7s %@",
            [[self.name stringByReplacingOccurrencesOfString:@"_" withString:@" "] UTF8String],
            [self.ranks intValue], fmodf([self.ranks floatValue], 1.0f)*100,
            [mindstate UTF8String],
            diffStr];
}

@end
