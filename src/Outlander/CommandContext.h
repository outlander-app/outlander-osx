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

@property (nonatomic, copy) NSString *scriptName;
@property (nonatomic, assign) int scriptLine;
@property (nonatomic, assign) int scriptColumn;

@property (nonatomic, assign) BOOL isSystemCommand;

@end
