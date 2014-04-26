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
    return [NSString stringWithFormat:@"%16s %4d %02.0f%% %2s/34", [self.name UTF8String], [self.ranks intValue], fmodf([self.ranks floatValue], 1.0f)*100, [[@(self.mindState.rateId) stringValue] UTF8String]];
}

@end
