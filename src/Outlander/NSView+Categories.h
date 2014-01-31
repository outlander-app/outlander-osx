//
//  NSView+Categories.h
//  Outlander
//
//  Created by Joseph McBride on 1/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//
// http://stackoverflow.com/a/843870/279764

#import <Cocoa/Cocoa.h>

@interface NSView (Categories)
- (void)fixLeftEdge:(BOOL)fixed;
- (void)fixRightEdge:(BOOL)fixed;
- (void)fixTopEdge:(BOOL)fixed;
- (void)fixBottomEdge:(BOOL)fixed;
- (void)fixWidth:(BOOL)fixed;
- (void)fixHeight:(BOOL)fixed;
@end
