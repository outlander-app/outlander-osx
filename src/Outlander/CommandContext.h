//
//  CommandContext.h
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TextTag.h"

@interface CommandContext : NSObject

@property (nonatomic, copy) NSString *command;
@property (nonatomic, strong) TextTag *tag;

@end
