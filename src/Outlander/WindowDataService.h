//
//  WindowDataService.h
//  Outlander
//
//  Created by Joseph McBride on 5/1/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "WindowData.h"
#import "GameContext.h"
#import "Layout.h"

@interface WindowDataService : NSObject

- (Layout *)readLayoutJson:(GameContext *)context;
- (void)write:(GameContext *)context LayoutJson:(Layout *)layout;

//- (WindowData *)dataFor:(NSDictionary *)json;
//- (NSArray *)readWindowJson:(GameContext *)context;
//- (void)write:(GameContext *)context WindowJson:(NSArray *)windows;
@end
