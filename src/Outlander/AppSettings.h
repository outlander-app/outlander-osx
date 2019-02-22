//
//  AppSettings.h
//  Outlander
//
//  Created by Joseph McBride on 5/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface AppSettings : NSObject

@property (nonatomic, copy) NSString *defaultProfile;
@property (nonatomic, copy) NSString *profile;
@property (nonatomic, copy) NSString *game;
@property (nonatomic, copy) NSString *character;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, copy) NSString *layout;

@property (nonatomic, assign) BOOL loggingEnabled;
@property (nonatomic, assign) BOOL rawLoggingEnabled;

@property (nonatomic, assign) BOOL checkForApplicationUpdates;
@property (nonatomic, assign) BOOL downloadPreReleaseVersions;

@property (nonatomic, copy) NSString *homeDirectory;
@property (nonatomic, copy) NSString *configFolder;
@property (nonatomic, copy) NSString *layoutFolder;
@property (nonatomic, copy) NSString *logsFolder;
@property (nonatomic, copy) NSString *profilesFolder;
@property (nonatomic, copy) NSString *scriptsFolder;
@property (nonatomic, copy) NSString *mapsFolder;
@property (nonatomic, copy) NSString *soundsFolder;

@property (nonatomic, copy) NSString *variableDateFormat;
@property (nonatomic, copy) NSString *variableTimeFormat;
@property (nonatomic, copy) NSString *variableDatetimeFormat;

- (BOOL)isValid;
- (void)copyFrom:(AppSettings *)settings;

@end
