//
//  VarCommandHandler.m
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "VarCommandHandler.h"
#import "NSString+Categories.h"
#import "OUtlander-Swift.h"

@implementation VarCommandHandler

- (BOOL)canHandle:(NSString *)command {
    return [command hasPrefix:@"#var"];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    NSMutableArray *commands = (NSMutableArray *)[[command substringFromIndex:4] componentsSeparatedByString:@" "];
    [commands removeObject:@""];
    
    if(commands && commands.count > 0) {
        NSString *key = commands[0];
        NSString *value = [self items:commands after:0];

        [context.globalVars setCacheObject:value forKey:key];
    }
}

- (NSString *) items:(NSArray *)items after:(NSInteger)index {
    NSMutableString *str = [[NSMutableString alloc] init];
   
    [items enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if(idx > index) {
            [str appendFormat:@"%@ ", obj];
        }
    }];
    
    return [str trimWhitespaceAndNewline];
}

@end
