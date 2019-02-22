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
    
    self.defaultProfile = @"Default";
    self.profile = @"Default";
    self.game = @"DR";
    self.account = @"";
    self.password = @"";
    self.character = @"";

    self.layout = @"default.cfg";

    self.homeDirectory = @"Outlander";
    self.configFolder = @"Config";
    self.layoutFolder = @"Layout";
    self.logsFolder = @"Logs";
    self.profilesFolder = @"Profiles";
    self.scriptsFolder = @"Scripts";
    self.mapsFolder = @"Maps";
    self.soundsFolder = @"Sounds";

    self.loggingEnabled = NO;
    self.rawLoggingEnabled = NO;

    self.checkForApplicationUpdates = YES;
    self.downloadPreReleaseVersions = NO;

    self.variableDateFormat = @"yyyy-MM-dd";
    self.variableTimeFormat = @"hh:mm:ss a";
    self.variableDatetimeFormat = @"yyyy-MM-dd hh:mm:ss a";
    
    return self;
}

- (BOOL)isValid {
    return
        self.account && self.account.length > 0
        && self.password && self.password.length > 0
        && self.game && self.game.length > 0
        && self.character && self.character.length > 0;
}

- (void)copyFrom:(AppSettings *)settings {
    self.defaultProfile = settings.defaultProfile;
    self.profile = settings.profile;
    self.game = settings.game;
    self.account = settings.account;
    self.character = settings.character;

    self.loggingEnabled = settings.loggingEnabled;
    self.rawLoggingEnabled = settings.rawLoggingEnabled;

    self.checkForApplicationUpdates = settings.checkForApplicationUpdates;
    self.downloadPreReleaseVersions = settings.downloadPreReleaseVersions;

    self.variableDateFormat = settings.variableDateFormat;
    self.variableTimeFormat = settings.variableTimeFormat;
    self.variableDatetimeFormat = settings.variableDatetimeFormat;
}

@end
