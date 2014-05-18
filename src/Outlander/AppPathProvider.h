//
//  AppPathProvider.h
//  Outlander
//
//  Created by Joseph McBride on 5/8/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AppSettings.h"

@interface AppPathProvider : NSObject

- (id)initWithSettings:(AppSettings *)settings;
- (NSString *)logsFolder;
- (NSString *)configFolder;
- (NSString *)profileFolder;
- (NSString *)folderForProfile:(NSString *)profile;

@end
