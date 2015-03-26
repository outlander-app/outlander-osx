//
//  Macro.h
//  Outlander
//
//  Created by Joseph McBride on 6/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface Macro : NSObject

@property (nonatomic, copy) NSString *keys;
@property (nonatomic, assign) NSUInteger keyCode;
@property (nonatomic, assign) NSUInteger modifiers;
@property (nonatomic, copy) NSString *action;

@end
