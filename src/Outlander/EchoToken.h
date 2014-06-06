//
//  EchoToken.h
//  Outlander
//
//  Created by Joseph McBride on 6/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Token.h"

@interface EchoToken : NSObject <Token>

@property (nonatomic, strong) NSMutableArray *tokens;

@end
