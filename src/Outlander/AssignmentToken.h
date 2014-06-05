//
//  AssignmentToken.h
//  Outlander
//
//  Created by Joseph McBride on 6/5/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Token.h"

@interface AssignmentToken : NSObject <Token>

@property (nonatomic, strong) id<Token> right;
@property (nonatomic, strong) id<Token> left;

-(instancetype)initWith:(id<Token>)right and:(id<Token>)left;

@end
