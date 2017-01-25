//
//  ScriptLoader.h
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "FileSystem.h"

@class GameContext;

@interface ScriptLoader : NSObject

- (instancetype)initWith:(GameContext *)context and:(id<FileSystem>)fileSystem;
- (NSString *)load:(NSString *)scriptName;
- (BOOL)exists:(NSString *)scriptName;

@end
