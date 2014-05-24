//
//  GameContext.h
//  Outlander
//
//  Created by Joseph McBride on 5/7/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AppSettings.h"
#import "AppPathProvider.h"
#import "TSMutableDictionary.h"

@interface GameContext : NSObject

@property (nonatomic, strong) AppPathProvider *pathProvider;
@property (nonatomic, strong) AppSettings *settings;
@property (nonatomic, strong) NSArray *windows;
@property (nonatomic, strong) NSMutableArray *highlights;
@property (nonatomic, strong) NSMutableArray *aliases;
@property (nonatomic, strong) TSMutableDictionary *globalVars;

@end
