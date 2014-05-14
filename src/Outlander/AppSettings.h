//
//  AppSettings.h
//  Outlander
//
//  Created by Joseph McBride on 5/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface AppSettings : NSObject

@property (nonatomic, copy) NSString *profile;
@property (nonatomic, copy) NSString *game;
@property (nonatomic, copy) NSString *character;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, copy) NSString *homeDirectory;
@property (nonatomic, copy) NSString *configFolder;
@property (nonatomic, copy) NSString *logsFolder;
@property (nonatomic, copy) NSString *profilesFolder;
@property (nonatomic, copy) NSString *scriptsFolder;

@end
