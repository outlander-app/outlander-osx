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
        
        NSString *action = commands[0];
        NSString *target = commands[1];
        NSString *param = @"";
        NSMutableArray<NSString *> *param2 = [NSMutableArray new];

        if (commands.count > 2) {
            param = commands[2];
        }

        if (commands.count > 3) {
            [commands enumerateObjectsUsingBlock:^(NSString* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(idx > 2) {
                    [param2 addObject:obj];
                }
            }];
        }
        
        NSDictionary *dict = @{ @"target": target, @"action": action, @"param": param, @"param2": param2};
        [context.events publish: @"script" data: dict];
    }
}

@end
