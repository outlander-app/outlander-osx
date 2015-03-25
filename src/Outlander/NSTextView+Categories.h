//
//  NSTextView+Categories.h
//  Outlander
//
//  Created by Joseph McBride on 3/24/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (Categories)

- (unsigned int) numberOfLines;
- (NSArray *) lines;

@end
