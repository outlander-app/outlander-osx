//
//  VarToken.h
//  Outlander
//
//  Created by Joseph McBride on 6/4/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Token.h"

@interface VarToken : NSObject <Token>

- (instancetype)initWith:(NSString *)val;

@end
