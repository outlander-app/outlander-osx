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
    NSArray *_skillsetSort;
}

-(instancetype)init {
    self = [super init];
    if(!self) return nil;
    
    _skills = [[TSMutableDictionary alloc] initWithName:@"exp_tracker"];
    
    _skillsetSort = @[@"Shield_Usage", @"Light_Armor", @"Chain_Armor", @"Brigandine", @"Plate_Armor", @"Defending", @"Parry_Ability", @"Small_Edged", @"Large_Edged", @"Twohanded_Edged", @"Small_Blunt", @"Large_Blunt", @"Twohanded_Blunt", @"Slings", @"Bow", @"Crossbow", @"Staves", @"Polearms", @"Light_Thrown", @"Heavy_Thrown", @"Brawling", @"Offhand_Weapon", @"Melee_Mastery", @"Missile_Mastery", @"Expertise", @"Elemental_Magic", @"Holy_Magic", @"Inner_Fire", @"Inner_Magic", @"Life_Magic", @"Attunement", @"Arcana", @"Targeted_Magic", @"Augmentation", @"Debilitation", @"Utility", @"Warding", @"Sorcery", @"Theurgy", @"Astrology", @"Summoning", @"Conviction", @"Evasion", @"Athletics", @"Perception", @"Stealth", @"Locksmithing", @"Thievery", @"First_Aid", @"Outdoorsmanship", @"Skinning", @"Scouting", @"Backstab", @"Thantology", @"Forging", @"Engineering", @"Outfitting", @"Alchemy", @"Enchanting", @"Scholarship", @"Mechanical_Lore", @"Appraisal", @"Performance", @"Tactics", @"Bardic_Lore", @"Empathy", @"Trading"];
    
    return self;
}

-(void) update:(SkillExp *)exp {
    
    if(exp == nil) return;

    if(self.startOfTracking == nil) {
        self.startOfTracking = [NSDate date];
    }
    
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
    
    return [self orderBySkillset:array];
}

-(NSArray *)orderBySkillset:(NSArray *)array {
    return [array sortedArrayUsingComparator:^NSComparisonResult(SkillExp *obj1, SkillExp *obj2) {
        
        NSUInteger idx1 = [_skillsetSort indexOfObject:obj1.name];
        NSUInteger idx2 = [_skillsetSort indexOfObject:obj2.name];
        
        if (idx1 < idx2) {
            return -1;
        }
        
        if (idx1 > idx2) {
            return 1;
        }
        
        return 0;
    }];
}

-(NSArray *)orderByRank:(NSArray *)array {
    return [array sortedArrayUsingComparator:^NSComparisonResult(SkillExp *obj1, SkillExp *obj2) {
        
        if (obj1.ranks.doubleValue < obj1.ranks.doubleValue) {
            return -1;
        }
        
        if (obj1.ranks.doubleValue > obj2.ranks.doubleValue) {
            return 1;
        }
        
        return 0;
    }];
}

-(NSArray *)orderByName:(NSArray *)array {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}
@end
