//
//  PauseToken.h
//  Outlander
//
//  Created by Joseph McBride on 6/5/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Token.h"

@interface PauseToken : NSObject <Token>

@property (nonatomic, assign) NSUInteger lineNumber;

- (instancetype)initWith:(NSNumber *)val;

@end
