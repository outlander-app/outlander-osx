//
//  MacrosLoader.h
//  Outlander
//
//  Created by Joseph McBride on 6/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "FileSystem.h"
#import "GameContext.h"
#import "Macro.h"

@interface MacrosLoader : NSObject

- (id)initWithContext:(GameContext *)context andFileSystem:(id<FileSystem>)fileSystem;
- (void)load;
- (void)save;

@end
