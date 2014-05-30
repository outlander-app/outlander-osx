//
//  ScriptRunner.h
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameContext.h"
#import "FileSystem.h"
#import "GameStream.h"

@interface ScriptRunner : NSObject

- (instancetype)initWith:(GameContext *)context and:(id<FileSystem>)fileSystem;
- (void)setGameStream:(id<InfoStream>)stream;
- (void)run:(NSString *)scriptName withArgs:(NSArray *)args;
- (void)pause:(NSString *)scriptName;
- (void)resume:(NSString *)scriptName;
- (void)abort:(NSString *)scriptName;

@end
