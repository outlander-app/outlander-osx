//
//  NSTextField+Categories.m
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "NSTextField+Categories.h"

@implementation NSTextField (Categories)

-(void)selectTextRange:(NSRange)range
{
    NSText *textEditor = [self.window fieldEditor:YES forObject:self];
    if( textEditor ) {
        id cell = [self selectedCell];
        [cell selectWithFrame:[self bounds] inView:self
                       editor:textEditor delegate:self
                        start:range.location length:range.length];
    }
}

@end
