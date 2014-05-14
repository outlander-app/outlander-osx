//
//  ProfileLoader.h
//  Outlander
//
//  Created by Joseph McBride on 5/8/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameContext.h"

@interface ProfileLoader : NSObject

- (id)initWithContext:(GameContext *)context;
- (void)load;

@end
