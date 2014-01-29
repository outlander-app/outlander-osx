//
//  MyThumb.m
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MyThumb.h"

@implementation MyThumb

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
    [[NSColor purpleColor] setFill];
    NSRectFill(dirtyRect);
    
	[super drawRect:self.bounds];
}

- (void) mouseDown:(NSEvent *)theEvent {
    if(self.down != nil) self.down(theEvent);
}

- (void) mouseDragged:(NSEvent *)theEvent {
    if(self.dragged != nil) self.dragged(theEvent);
}

- (void) mouseUP:(NSEvent *)theEvent {
    if(self.up != nil) self.up(theEvent);
}
@end
