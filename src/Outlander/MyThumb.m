//
//  MyThumb.m
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MyThumb.h"

@implementation MyThumb {
    NSCursor *_cursor;
    NSTrackingArea *_trackingArea;
}

- (id)initWithFrame:(NSRect)frame withCursor:(NSCursor *)cursor {
    self = [super initWithFrame:frame];
    if (self) {
        
        _cursor = cursor;
        [self createTrackingArea];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
//    [[NSColor purpleColor] setFill];
//    NSRectFill(dirtyRect);
//    
	[super drawRect:self.bounds];
}

- (void) cursorUpdate:(NSEvent *)event {
    [_cursor set];
}

- (void) updateTrackingAreas {
    
    if(_trackingArea) {
        [self removeTrackingArea:_trackingArea];
    }
    
    [self createTrackingArea];
    [super updateTrackingAreas];
}

- (void)createTrackingArea {
    _trackingArea = [[NSTrackingArea alloc] initWithRect: self.bounds
                                                        options: NSTrackingActiveInActiveApp | NSTrackingCursorUpdate
                                                          owner: self
                                                       userInfo: nil];
    [self addTrackingArea:_trackingArea];
}

- (void) mouseDown:(NSEvent *)theEvent {
    if(self.down != nil) self.down(theEvent);
}

- (void) mouseDragged:(NSEvent *)theEvent {
    if(self.dragged != nil) self.dragged(theEvent);
}

- (void) mouseUp:(NSEvent *)theEvent {
    if(self.up != nil) self.up(theEvent);
}

- (void)mouseEntered:(NSEvent *)event;
{
//    NSPoint location = [self.helpView convertPoint:[event locationInWindow] fromView:nil];
    // Do whatever you want to do in response to mouse entering
}

- (void)mouseExited:(NSEvent *)event;
{
//    NSPoint location = [self.helpView convertPoint:[event locationInWindow] fromView:nil];
    // Do whatever you want to do in response to mouse exiting
}

- (void)mouseMoved:(NSEvent *)event;
{
//    NSPoint location = [self.helpView convertPoint:[event locationInWindow] fromView:nil];
    // Do whatever you want to do in response to mouse movements
}
@end
