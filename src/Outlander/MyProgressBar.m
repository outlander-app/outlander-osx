//
//  MyProgressBar.m
//  Outlander
//
//  Created by Joseph McBride on 2/3/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MyProgressBar.h"

@implementation MyProgressBar


-(void)drawRect:(NSRect)dirtyRect {
    
    float height = self.frame.size.height;
    float width = self.frame.size.width;
    
    [[NSColor purpleColor] setFill];
    NSRectFill(NSMakeRect(0, 0, width, height));
    
	[super drawRect:self.bounds];
}

@end
