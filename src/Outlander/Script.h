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
#import "CommandRelay.h"

@interface Script : Actor

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) TSMutableDictionary *localVars;
@property (nonatomic, strong) NSCondition *pauseCondition;
@property (nonatomic, strong) NSMutableArray *matchList;

- (instancetype)initWith:(GameContext *)context and:(NSString *)data;
- (void)setData:(NSString *)data;
- (void)setGameStream:(id<InfoStream>)stream;
- (void)setCommandRelay:(id<CommandRelay>)relay;

@end
