//
//  MacroHandler.m
//  Outlander
//
//  Created by Joseph McBride on 6/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MacroHandler.h"
#import "TextTag.h"

@interface MacroHandler () {
    GameContext *_context;
    id<CommandRelay> _commandRelay;
}
@end

@implementation MacroHandler

- (instancetype)initWith:(GameContext *)context and:(id<CommandRelay>)commandRelay {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    _commandRelay = commandRelay;
    
    return self;
}

- (BOOL)handle:(NSEvent *)theEvent {
    unichar val = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    NSUInteger modifiers = [theEvent modifierFlags];
    NSNumber *number = [NSNumber numberWithUnsignedChar:val];
    return [self handle:number with:modifiers];
}

- (BOOL)handle:(NSNumber *)key with:(NSUInteger)modifiers {
    
    __block BOOL handled = NO;
    
    [_context.macros enumerateObjectsUsingBlock:^(Macro *obj, NSUInteger idx, BOOL *stop) {
        if([obj.keys isEqualToNumber:key]) {
            handled = YES;
            
            CommandContext *ctx = [[CommandContext alloc] init];
            ctx.command = obj.action;
            ctx.tag = [TextTag tagFor:[NSString stringWithFormat:@"%@\n", obj.action] mono:YES];
            ctx.tag.color = @"#ACFF2F";
            
            [_commandRelay sendCommand:ctx];
        }
    }];
    
    return handled;
}

@end
