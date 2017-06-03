//
//  LearningRate.h
//  Outlander
//
//  Created by Joseph McBride on 4/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface LearningRate : NSObject

@property (nonatomic, assign) UInt16 rateId;
@property (nonatomic, copy, nonnull) NSString *desc;

+(NSDictionary* _Nonnull)learningRates;
+(LearningRate * _Nonnull)fromRate:(UInt16)rate;
+(LearningRate * _Nullable)fromDescription:(NSString * _Nonnull)desc;

+(id _Nonnull)learningRate:(UInt16)rateId description:(NSString * _Nonnull)description;
-(id _Nonnull)initWith:(UInt16)rateId description:(NSString *_Nonnull)description;

@end
