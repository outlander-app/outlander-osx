//
//  AppSettingsLoader.h
//  Outlander
//
//  Created by Joseph McBride on 5/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@class GameContext;

@interface AppSettingsLoader : NSObject

- (id)initWithContext:(GameContext *)context;
- (void)load;
- (void)saveProfile;
- (void)saveVariables;
- (void)saveHighlights;
- (void)saveAliases;
- (void)saveMacros;

@end
