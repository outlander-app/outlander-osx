//
//  AppSettings.m
//  Outlander
//
//  Created by Joseph McBride on 5/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AppSettings.h"

@implementation AppSettings

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.profile = @"Default";
    self.game = @"DR";
    
    self.homeDirectory = @"Outlander";
    self.configFolder = @"Config";
    self.logsFolder = @"Logs";
    self.profilesFolder = @"Profiles";
    self.scriptsFolder = @"Scripts";
    
    return self;
}

@end
