//
//  LearningRate.m
//  Outlander
//
//  Created by Joseph McBride on 4/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "LearningRate.h"

@implementation LearningRate

+(NSDictionary *)learningRates {
    static NSDictionary *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @{
                 @"0": [LearningRate learningRate:0 description:@"clear"],
                 @"1": [LearningRate learningRate:1 description:@"dabbling"],
                 @"2": [LearningRate learningRate:2 description:@"perusing"],
                 @"3": [LearningRate learningRate:3 description:@"learning"],
                 @"4": [LearningRate learningRate:4 description:@"thoughtful"],
                 @"5": [LearningRate learningRate:5 description:@"thinking"],
                 @"6": [LearningRate learningRate:6 description:@"considering"],
                 @"7": [LearningRate learningRate:7 description:@"pondering"],
                 @"8": [LearningRate learningRate:8 description:@"ruminating"],
                 @"9": [LearningRate learningRate:9 description:@"concentrating"],
                 @"10": [LearningRate learningRate:10 description:@"attentive"],
                 @"11": [LearningRate learningRate:11 description:@"deliberative"],
                 @"12": [LearningRate learningRate:12 description:@"interested"],
                 @"13": [LearningRate learningRate:13 description:@"examining"],
                 @"14": [LearningRate learningRate:14 description:@"understanding"],
                 @"15": [LearningRate learningRate:15 description:@"absorbing"],
                 @"16": [LearningRate learningRate:16 description:@"intrigued"],
                 @"17": [LearningRate learningRate:17 description:@"scrutinizing"],
                 @"18": [LearningRate learningRate:18 description:@"analyzing"],
                 @"19": [LearningRate learningRate:19 description:@"studious"],
                 @"20": [LearningRate learningRate:20 description:@"focused"],
                 @"21": [LearningRate learningRate:21 description:@"very focused"],
                 @"22": [LearningRate learningRate:22 description:@"engaged"],
                 @"23": [LearningRate learningRate:23 description:@"very engaged"],
                 @"24": [LearningRate learningRate:24 description:@"cogitating"],
                 @"25": [LearningRate learningRate:25 description:@"fascinated"],
                 @"26": [LearningRate learningRate:26 description:@"captivated"],
                 @"27": [LearningRate learningRate:27 description:@"engrossed"],
                 @"28": [LearningRate learningRate:28 description:@"riveted"],
                 @"29": [LearningRate learningRate:29 description:@"very riveted"],
                 @"30": [LearningRate learningRate:30 description:@"rapt"],
                 @"31": [LearningRate learningRate:31 description:@"very rapt"],
                 @"32": [LearningRate learningRate:32 description:@"enthralled"],
                 @"33": [LearningRate learningRate:33 description:@"nearly locked"],
                 @"34": [LearningRate learningRate:34 description:@"mind lock"],
                 };
    });
    return inst;
}

+(LearningRate *)fromDescription:(NSString *)desc {
    __block LearningRate *rate = nil;
    [[LearningRate learningRates] enumerateKeysAndObjectsUsingBlock:^(NSString *key, LearningRate *obj, BOOL *stop) {
        if([obj.desc isEqualToString:desc]){
            rate = obj;
            *stop = YES;
        }
    }];
    
    return rate;
}

+(LearningRate *)fromRate:(UInt16)rate {
    return [[LearningRate learningRates] objectForKey:[NSString stringWithFormat:@"%hu", rate]];
}

+(id)learningRate:(UInt16)rateId description:(NSString *)description {
    return [[super alloc] initWith:rateId description:description];
}

-(id)initWith:(UInt16)rateId description:(NSString *)description {
    self = [super init];
    if(!self) return nil;
    
    _rateId = rateId;
    _desc = description;
    
    return self;
}

-(BOOL)isEqualToLearningRate:(LearningRate *)rate {
    if(!rate)
        return NO;
    
    return self.rateId == rate.rateId && [self.desc isEqualToString:rate.desc];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[LearningRate class]]) {
        return NO;
    }
    
    return [self isEqualToLearningRate:(LearningRate *)object];
}

- (NSUInteger)hash {
    return self.rateId ^ [self.desc hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"LearningRate: %@ (%hu)", self.desc, self.rateId];
}

@end
