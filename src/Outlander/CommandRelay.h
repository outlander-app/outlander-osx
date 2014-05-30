//
//  CommandRelay.h
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "CommandContext.h"
#import "TextTag.h"

@protocol CommandRelay <NSObject>

- (void)sendCommand:(CommandContext *)ctx;
- (void)sendEcho:(TextTag *)tag;

@end
