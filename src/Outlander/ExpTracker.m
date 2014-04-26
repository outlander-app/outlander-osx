//
//  ExpTracker.m
//  Outlander
//
//  Created by Joseph McBride on 4/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ExpTracker.h"
#import "TSMutableDictionary.h"
#import "ReactiveCocoa.h"

@implementation ExpTracker {
    TSMutableDictionary *_skills;
}

-(id)init {
    self = [super init];
    if(!self) return nil;
    
    _skills = [[TSMutableDictionary alloc] initWithName:@"exp_tracker"];
    
    return self;
}

-(void) update:(SkillExp *)exp {
    SkillExp *skill = nil;
    
    if(!skill) {
        skill = exp;
        [_skills setCacheObject:exp forKey:exp.name];
    } else {
        skill = [_skills cacheObjectForKey:exp.name];
    }
    
    skill.ranks = exp.ranks;
    skill.isNew = exp.isNew;
    skill.mindState = exp.mindState;
}

-(NSArray *) skills {
    return _skills.allItems;
}

-(NSArray *) skillsWithExp {
    return [_skills.allItems.rac_sequence filter:^BOOL(SkillExp *item) {
        return item.isNew;
    }].array;
}
@end
