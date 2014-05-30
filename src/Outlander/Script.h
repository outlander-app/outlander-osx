//
//  Script.h
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Actor.h"
#import "GameContext.h"
#import "TSMutableDictionary.h"
#import "GameStream.h"

@interface Script : Actor

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) TSMutableDictionary *localVars;

- (instancetype)initWith:(GameContext *)context and:(NSString *)data;
- (void)setGameStream:(id<InfoStream>)stream;

@end
