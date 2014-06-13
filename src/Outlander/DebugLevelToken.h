//
//  DebugLevelToken.h
//  Outlander
//
//  Created by Joseph McBride on 6/12/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Token.h"

@interface DebugLevelToken : NSObject <Token>

@property (nonatomic, assign) NSUInteger lineNumber;

- (instancetype)initWith:(NSNumber *)val;

@end
