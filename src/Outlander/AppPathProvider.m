//
//  AppPathProvider.m
//  Outlander
//
//  Created by Joseph McBride on 5/8/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AppPathProvider.h"

@interface AppPathProvider () {
    AppSettings *_settings;
}
@end

@implementation AppPathProvider

- (id)initWithSettings:(AppSettings *)settings {
    self = [super init];
    if(!self) return nil;
    
    _settings = settings;
    
    return self;
}

- (NSString *)rootFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *homeFolder = [documentDirectory stringByAppendingPathComponent:_settings.homeDirectory];
    return homeFolder;
}

- (NSString *)configFolder {
    return [[self rootFolder] stringByAppendingPathComponent:_settings.configFolder];
}

- (NSString *)layoutFolder {
    return [[self configFolder] stringByAppendingPathComponent:_settings.layoutFolder];
}

- (NSString *)logsFolder {
    return [[self rootFolder] stringByAppendingPathComponent:_settings.logsFolder];
}

- (NSString *)scriptsFolder {
    return [[self rootFolder] stringByAppendingPathComponent:_settings.scriptsFolder];
}

- (NSString *)mapsFolder {
    return [[self rootFolder] stringByAppendingPathComponent:_settings.mapsFolder];
}

- (NSString *)soundsFolder {
    return [[self rootFolder] stringByAppendingPathComponent:_settings.soundsFolder];
}

- (NSString *)profileFolder {
    return [self folderForProfile:_settings.profile];
}

- (NSString *)folderForProfile:(NSString *)profile {
    NSString *profilesFolder = [[self configFolder] stringByAppendingPathComponent:_settings.profilesFolder];
    return [profilesFolder stringByAppendingPathComponent:profile];
}

@end
