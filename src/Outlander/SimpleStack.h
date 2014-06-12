//
//  SimpleStack.h
//  Outlander
//
//  Created by Joseph McBride on 6/11/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface SimpleStack : NSObject

- (id)pop;
- (void)push:(id)item;
- (NSUInteger)count;

@end
