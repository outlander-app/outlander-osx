//
//  HighlightsLoader.h
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "FileSystem.h"
#import "Highlight.h"

@class GameContext;

@interface HighlightsLoader : NSObject

- (id)initWithContext:(GameContext *)context andFileSystem:(id<FileSystem>)fileSystem;
- (void)load;
- (void)save;

@end
