//
//  MyNSTextField.m
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MyNSTextField.h"

@implementation MyNSTextField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

-(BOOL) becomeFirstResponder
{
    BOOL    success = [super becomeFirstResponder];
    if( success )
    {
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

@end
