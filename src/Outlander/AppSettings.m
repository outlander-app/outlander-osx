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
    self.account = @"";
    self.password = @"";
    self.character = @"";
   
    self.homeDirectory = @"Outlander";
    self.configFolder = @"Config";
    self.logsFolder = @"Logs";
    self.profilesFolder = @"Profiles";
    self.scriptsFolder = @"Scripts";
    self.mapsFolder = @"Maps";
    self.soundsFolder = @"Sounds";
    
    return self;
}

- (BOOL)isValid {
    return
        self.account && self.account.length > 0
        && self.password && self.password.length > 0
        && self.game && self.game.length > 0
        && self.character && self.character.length > 0;
}

@end
