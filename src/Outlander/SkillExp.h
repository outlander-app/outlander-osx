//
//  SkillExp.h
//  Outlander
//
//  Created by Joseph McBride on 4/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "LearningRate.h"

@interface SkillExp : NSObject

@property (nonatomic, copy, nonnull) NSString *name;
@property (nonatomic, strong, nonnull) LearningRate *mindState;
@property (nonatomic, strong, nonnull) NSDecimalNumber *ranks;
@property (nonatomic, strong, nonnull) NSDecimalNumber *originalRanks;
@property (nonatomic, assign) BOOL isNew;

@end
