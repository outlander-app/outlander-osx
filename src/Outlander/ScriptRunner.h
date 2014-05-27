//
//  ScriptRunner.h
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameContext.h"
#import "FileSystem.h"

@interface ScriptRunner : NSObject

- (instancetype)initWith:(GameContext *)context and:(id<FileSystem>)fileSystem;
- (void)run:(NSString *)scriptName withArgs:(NSArray *)args;
- (void)pause:(NSString *)scriptName;
- (void)resume:(NSString *)scriptName;
- (void)abort:(NSString *)scriptName;

@end
