//
//  VarCommandHandler.m
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "VarCommandHandler.h"

@implementation VarCommandHandler

- (BOOL)canHandle:(NSString *)command {
    return [command hasPrefix:@"#var"];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    NSMutableArray *commands = (NSMutableArray *)[[command substringFromIndex:4] componentsSeparatedByString:@" "];
    [commands removeObject:@""];
    
    if(commands && commands.count > 0) {
        NSString *key = commands[0];
        NSString *value = commands[1];
        
        [context.globalVars setCacheObject:value forKey:key];
    }
}

@end
