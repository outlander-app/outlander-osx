//
//  LRToken.h
//  Outlander
//
//  Created by Joseph McBride on 6/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Token.h"

@interface LRToken : NSObject <Token>

@property (nonatomic, strong) id<Token> right;
@property (nonatomic, strong) id<Token> left;

-(instancetype)initWith:(id<Token>)right and:(id<Token>)left;

@end
