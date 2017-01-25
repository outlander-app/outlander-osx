//
//  HighlightCommandHandler.m
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "HighlightCommandHandler.h"
#import "Highlight.h"
#import "HighlightsLoader.h"
#import "NSString+Categories.h"
#import "Outlander-Swift.h"

@implementation HighlightCommandHandler

- (BOOL)canHandle:(NSString *)command {
    return [[command lowercaseString] hasPrefix:@"#highlight"];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    NSMutableArray *commands = (NSMutableArray *)[[command substringFromIndex:10] componentsSeparatedByString:@" "];
    [commands removeObject:@""];
    
    if(commands && commands.count > 0) {

        if([commands[0] isEqualToString:@"reload"]) {
            HighlightsLoader *loader = [[HighlightsLoader alloc] initWithContext:context andFileSystem:[[LocalFileSystem alloc] init]];
            [loader load];
            [context.events echoText:@"Highlights reloaded" mono:true preset:@""];
            return;
        }
        
        NSString *color = commands[0];
        NSString *pattern = [self items:commands after:0];
        
        __block Highlight *hl;
        
        [context.highlights enumerateObjectsUsingBlock:^(Highlight *check, NSUInteger idx, BOOL *stop) {
            
            if([check.pattern isEqualToString:pattern]) {
                hl = check;
                *stop = YES;
            }
        }];
        
        if(!hl) {
            hl = [[Highlight alloc] init];
            hl.pattern = pattern;
            hl.color = color;
            [context.highlights addObject:hl];
        }
        else {
            // change color and signal update
            hl.color = color;
            [context.highlights signalChange:hl];
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
