//
//  CommandHandler.h
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameContext.h"

@protocol CommandHandler <NSObject>

- (BOOL)canHandle:(NSString *)command;
- (void)handle:(NSString *)command withContext:(GameContext *)context;

@end
