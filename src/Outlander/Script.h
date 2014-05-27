//
//  Script.h
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Actor.h"
#import "GameContext.h"

@interface Script : Actor

@property (nonatomic, copy) NSString *name;

- (instancetype)initWith:(GameContext *)context and:(NSString *)data;

@end
