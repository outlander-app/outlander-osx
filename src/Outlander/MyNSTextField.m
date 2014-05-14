//
//  MyNSTextField.m
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MyNSTextField.h"

@interface MyNSTextField () {
    NSMutableArray *_history;
}
@end

@implementation MyNSTextField

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    _history = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
}

-(BOOL)becomeFirstResponder {
    BOOL success = [super becomeFirstResponder];
    if( success ) {
        // Strictly spoken, NSText (which currentEditor returns) doesn't
        // implement setInsertionPointColor:, but it's an NSTextView in practice.
        // But let's be paranoid, better show an invisible black-on-black cursor
        // than crash.
        NSTextView* textField = (NSTextView*) [self currentEditor];
        if( [textField respondsToSelector: @selector(setInsertionPointColor:)] )
            [textField setInsertionPointColor: [NSColor whiteColor]];
    }
    return success;
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    switch ([[theEvent charactersIgnoringModifiers] characterAtIndex:0]) {
        case NSUpArrowFunctionKey:
            return YES;
            break;
        case NSDownArrowFunctionKey:;
            return YES;
            break;
        default:
            break;
    }
    return [super performKeyEquivalent:theEvent];
}

@end
