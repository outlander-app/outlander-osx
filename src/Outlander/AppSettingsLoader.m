//
//  AppSettingsLoader.m
//  Outlander
//
//  Created by Joseph McBride on 5/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AppSettingsLoader.h"
#import "WindowDataService.h"
#import "ProfileLoader.h"

@interface AppSettingsLoader () {
    GameContext *_context;
    WindowDataService *_windowDataService;
    ProfileLoader *_profileLoader;
}
@end

@implementation AppSettingsLoader

- (id)initWithContext:(GameContext *)context {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    _windowDataService = [[WindowDataService alloc] init];
    _profileLoader = [[ProfileLoader alloc] initWithContext:_context];
    
    return self;
}

- (void)load {
    
    [self writeConfigFolders];
    [self loadConfig];
    
    [self writeProfileFolders:_context.settings.profile];
    [self loadProfile];
    
    [self loadHighlights];
    [self loadVariables];
}

- (void)loadConfig {
}

- (void)loadProfile {
    
    _context.windows = [_windowDataService readWindowJson:_context];
    [_profileLoader load];
}

- (void)saveProfile {
    
    [_windowDataService write:_context WindowJson:_context.windows];
    [_profileLoader save];
}

- (void)loadHighlights {
}

- (void)loadVariables {
}

- (void)writeConfigFolders {
    [self writeProfileFolders:@"Default"];
    [self ensurePath:[_context.pathProvider logsFolder]];
    [self ensurePath:[_context.pathProvider scriptsFolder]];
}

- (void)writeProfileFolders:(NSString *)profile {
    [self ensurePath:[_context.pathProvider folderForProfile:profile]];
}

- (void)ensurePath:(NSString *)path {
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]){
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if(error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
}

@end
