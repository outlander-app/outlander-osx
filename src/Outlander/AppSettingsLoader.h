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
- (void)loadProfile:(NSString *)profile;
- (void)load;

- (void)loadConfig;
- (void)saveConfig;

- (void)loadLayout:(NSString *)file;
- (void)saveLayout:(NSString *)file;

- (void)saveProfile;
- (void)saveVariables;
- (void)saveHighlights;
- (void)saveAliases;
- (void)saveMacros;
- (void)saveTriggers;
- (void)saveSubs;
- (void)saveGags;
- (void)savePresets;
- (void)saveVitals;

- (void)loadClassses;
- (void)saveClasses;

@end
