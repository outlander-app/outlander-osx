//
//  ScriptCommandHandler.m
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ScriptCommandHandler.h"
#import "Outlander-Swift.h"

@implementation ScriptCommandHandler

- (BOOL)canHandle:(NSString *)command {
    return [[command lowercaseString] hasPrefix:@"#script"];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    
    NSMutableArray *commands = (NSMutableArray *)[[command substringFromIndex:7] componentsSeparatedByString:@" "];
    [commands removeObject:@""];
    
    if(commands && commands.count > 1) {
        
        NSString *target = commands[1];
        NSString *action = commands[0];
        NSString *param = @"";
        
        if (commands.count > 2) {
            param = commands[2];
        }
        
        NSDictionary *dict = @{ @"target": target, @"action": action, @"param": param};
        [context.events publish: @"script" data: dict];
    }
}

@end
