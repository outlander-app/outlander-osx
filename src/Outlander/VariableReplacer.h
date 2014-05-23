//
//  VariableReplacer.h
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameContext.h"

@interface VariableReplacer : NSObject

- (NSString *)replace:(NSString *)data withContext:(GameContext *)context;

@end
