//
//  VariablesLoader.h
//  Outlander
//
//  Created by Joseph McBride on 5/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameContext.h"
#import "FileSystem.h"

@interface VariablesLoader : NSObject

- (id)initWithContext:(GameContext *)context andFileSystem:(id<FileSystem>)fileSystem;
- (void)load;
- (void)save;

@end
