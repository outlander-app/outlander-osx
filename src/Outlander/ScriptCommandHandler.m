//
//  ScriptCommandHandler.m
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ScriptCommandHandler.h"

@implementation ScriptCommandHandler

- (BOOL)canHandle:(NSString *)command {
    return [command hasPrefix:@"#script"];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    
    NSMutableArray *commands = (NSMutableArray *)[[command substringFromIndex:7] componentsSeparatedByString:@" "];
    [commands removeObject:@""];
    
    if(commands && commands.count > 0) {
        
        NSString *target = commands[1];
        NSString *action = commands[0];
        
        NSDictionary *dict = @{ @"target": target, @"action": action};
        
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"script"
                          object:self
                        userInfo:dict];
    }
}

@end
