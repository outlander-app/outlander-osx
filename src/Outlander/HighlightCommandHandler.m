//
//  HighlightCommandHandler.m
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "HighlightCommandHandler.h"
#import "Highlight.h"

@implementation HighlightCommandHandler

- (BOOL)canHandle:(NSString *)command {
    return [command hasPrefix:@"#highlight"];
}

- (void)handle:(NSString *)command withContext:(GameContext *)context {
    NSMutableArray *commands = (NSMutableArray *)[[command substringFromIndex:10] componentsSeparatedByString:@" "];
    [commands removeObject:@""];
    
    if(commands && commands.count > 0) {
        NSString *color = commands[0];
        NSString *pattern = commands[1];
        
        Highlight *hl = [[Highlight alloc] init];
        hl.color = color;
        hl.pattern = pattern;
        
        [context.highlights addObject:hl];
    }
}

@end
