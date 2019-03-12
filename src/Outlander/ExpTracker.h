//
//  ExpTracker.h
//  Outlander
//
//  Created by Joseph McBride on 4/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SkillExp.h"

@interface ExpTracker : NSObject

@property (nonatomic, copy) NSString *orderBy;
@property (nonatomic, strong) NSDate *startOfTracking;

-(void)reset;
-(void) update:(SkillExp *)exp;
-(NSArray *) skills;
-(NSArray *) skillsWithMindState;
-(NSArray *) skillsWithExpOrMindState;

@end
