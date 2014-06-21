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
#import "OLMutableArray.h"

@interface GameContext : NSObject

@property (nonatomic, strong) AppPathProvider *pathProvider;
@property (nonatomic, strong) AppSettings *settings;
@property (nonatomic, strong) NSArray *windows;
@property (nonatomic, strong) OLMutableArray *highlights;
@property (nonatomic, strong) OLMutableArray *aliases;
@property (nonatomic, strong) OLMutableArray *macros;
@property (nonatomic, strong) TSMutableDictionary *globalVars;

@end
