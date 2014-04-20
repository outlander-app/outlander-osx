//
//  LearningRate.h
//  Outlander
//
//  Created by Joseph McBride on 4/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LearningRate : NSObject

@property (nonatomic, assign) UInt16 rateId;
@property (nonatomic, copy) NSString *description;

+(NSDictionary*)learningRates;
+(LearningRate *)fromRate:(UInt16)rate;
+(LearningRate *)fromDescription:(NSString *)desc;

+(id)learningRate:(UInt16)rateId description:(NSString *)description;
-(id)initWith:(UInt16)rateId description:(NSString *)description;

@end
