//
//  BasicToken.h
//  Outlander
//
//  Created by Joseph McBride on 6/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Token.h"

@interface BasicToken : NSObject <Token>

@property (nonatomic, assign) NSUInteger lineNumber;

- (instancetype)initWith:(NSString *)val;

@end
