//
//  SettingsView.h
//  Outlander
//
//  Created by Joseph McBride on 6/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameContext.h"

@protocol SettingsView <NSObject>

- (void)save;
- (void)setContext:(GameContext *)context;

@end
