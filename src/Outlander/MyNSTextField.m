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
    NSInteger _currentHistory;
}
@end

@implementation MyNSTextField

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    return self;
}

- (void)awakeFromNib {
    _history = [[NSMutableArray alloc] init];
    _currentHistory = -1;
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
            [self previousHistory];
            return YES;
            break;
        case NSDownArrowFunctionKey:
            [self nextHistory];
            return YES;
            break;
        default:
            break;
    }
    return [super performKeyEquivalent:theEvent];
}

- (void)commitHistory {
    [_history addObject:self.stringValue];
    if(_history.count > 30) {
        [_history removeObjectAtIndex:0];
    }
    _currentHistory = -1;
}

- (void)previousHistory {
    _currentHistory -= 1;
    if(_currentHistory < 0)
        _currentHistory = _history.count - 1;
    
    NSString *val = [_history objectAtIndex:_currentHistory];
    [self setStringValue: val];
}

- (void)nextHistory {
    _currentHistory += 1;
    
    if(_currentHistory > (_history.count) -1)
        _currentHistory = 0;
    
    NSString *val = [_history objectAtIndex:_currentHistory];
    [self setStringValue: val];
}

@end
