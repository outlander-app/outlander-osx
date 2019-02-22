//
//  WindowDataService.h
//  Outlander
//
//  Created by Joseph McBride on 5/1/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "WindowData.h"
#import "Layout.h"

@class GameContext;

@interface WindowDataService : NSObject

- (Layout *)readFromFile:(NSString *)file withContext:(GameContext *)context;
- (void)write:(Layout *)layout toFile:(NSString *)file withContext:(GameContext *)context;

@end
