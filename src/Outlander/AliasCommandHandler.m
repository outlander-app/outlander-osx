//
//  AliasCommandHandler.m
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AliasCommandHandler.h"
#import "Alias.h"
#import "AliasLoader.h"
#import "NSString+Categories.h"
#import "Outlander-Swift.h"

@implementation AliasCommandHandler

- (BOOL)canHandle:(NSString *)command {
    return [[command lowercaseString] hasPrefix:@"#alias"];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    NSMutableArray *commands = (NSMutableArray *)[[command substringFromIndex:6] componentsSeparatedByString:@" "];
    [commands removeObject:@""];
    
    if(commands && commands.count > 0) {

        if([commands[0] isEqualToString:@"reload"]) {
            AliasLoader *loader = [[AliasLoader alloc] initWithContext:context andFileSystem:[[LocalFileSystem alloc] init]];
            [loader load];
            [context.events echoText:@"Aliases reloaded" mono:true preset:@""];
            return;
        }
        
        NSString *pattern = commands[0];
        NSString *replace = [self items:commands after:0];
        
        __block Alias *hl;
        
        [context.aliases enumerateObjectsUsingBlock:^(Alias *check, NSUInteger idx, BOOL *stop) {
            
            if([check.pattern isEqualToString:pattern]) {
                hl = check;
                *stop = YES;
            }
        }];
        
        if(!hl) {
            hl = [[Alias alloc] init];
            hl.pattern = pattern;
            hl.replace = replace;
            [context.aliases addObject:hl];
        }
        else {
            // change replace and signal update
            hl.replace = replace;
            [context.aliases signalChange:hl];
        }
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
