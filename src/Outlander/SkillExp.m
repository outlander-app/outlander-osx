//
//  SkillExp.m
//  Outlander
//
//  Created by Joseph McBride on 4/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SkillExp.h"

@implementation SkillExp

- (NSString *)description {
    NSString *mindstate = [NSString stringWithFormat:@"(%@/34)", @(self.mindState.rateId)];
    return [NSString stringWithFormat:@"%16s: %4d %02.0f%%  %7s", [[self.name stringByReplacingOccurrencesOfString:@"_" withString:@" "] UTF8String], [self.ranks intValue], fmodf([self.ranks floatValue], 1.0f)*100, [mindstate UTF8String]];
}

@end
