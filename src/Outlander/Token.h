//
//  Token.h
//  Outlander
//
//  Created by Joseph McBride on 6/4/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@protocol Token <NSObject>

@property (nonatomic, assign) NSUInteger lineNumber;

- (id)eval;

@end
