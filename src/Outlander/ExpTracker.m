//
//  ExpTracker.m
//  Outlander
//
//  Created by Joseph McBride on 4/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ExpTracker.h"
#import "TSMutableDictionary.h"

@implementation ExpTracker {
    TSMutableDictionary *_skills;
}

-(instancetype)init {
    self = [super init];
    if(!self) return nil;
    
    _skills = [[TSMutableDictionary alloc] initWithName:@"exp_tracker"];
    
    return self;
}

-(void) update:(SkillExp *)exp {
    
    if(exp == nil) return;
    
    SkillExp *skill = [_skills cacheObjectForKey:exp.name];
    
    if(skill == nil) {
        skill = exp;
        skill.originalRanks = exp.ranks;
        [_skills setCacheObject:exp forKey:exp.name];
    }
    
    skill.ranks = exp.ranks.doubleValue == 0.0 ? skill.ranks : exp.ranks;
    
    if (skill.originalRanks.doubleValue == 0.0) {
        skill.originalRanks = skill.ranks;
    }
    
    skill.isNew = exp.isNew;
    skill.mindState = exp.mindState;
}

-(NSArray *) skills {
    return _skills.allItems;
}

-(NSArray *) skillsWithExp {
    NSArray *array = [_skills.allItems.rac_sequence filter:^BOOL(SkillExp *item) {
        return item.mindState.rateId > 0;
    }].array;
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}
@end
