//
//  MyNSTextField.m
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MyNSTextField.h"
#import "NSColor+Categories.h"

@interface MyNSTextField () {
    NSMutableArray *_history;
    NSInteger _currentHistory;
}
@end

@implementation MyNSTextField

- (void)awakeFromNib {
    _history = [[NSMutableArray alloc] init];
    _currentHistory = -1;
    _progress = 0;
    
    [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.needsDisplay = YES;
}

-(void)drawRect:(NSRect)dirtyRect {
    
    NSRect progressRect = [self bounds];
    progressRect.size.width *= _progress;
    progressRect.origin.x += 2;
    
    [[NSColor colorWithHexString:@"#003366"] set];
    
    NSRectFillUsingOperation(progressRect, NSCompositeSourceOver);
    
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
    
    _currentHistory = -1;
    
    // don't commit the same item multiple times
    if(_history.count > 0 && [[_history objectAtIndex:_history.count-1] isEqualToString:self.stringValue])
        return;
    
    [_history addObject:self.stringValue];
    if(_history.count > 30) {
        [_history removeObjectAtIndex:0];
    }
}

- (void)previousHistory {
    _currentHistory -= 1;
    if(_currentHistory < 0)
        _currentHistory = _history.count - 1;
    
    NSString *val = [_history objectAtIndex:_currentHistory];
    [self setStringValue: val];
    [[self currentEditor] moveToEndOfLine:nil];
}

- (void)nextHistory {
    _currentHistory += 1;
    
    if(_currentHistory > (_history.count) -1)
        _currentHistory = 0;
    
    NSString *val = [_history objectAtIndex:_currentHistory];
    [self setStringValue: val];
    [[self currentEditor] moveToEndOfLine:nil];
}

@end
