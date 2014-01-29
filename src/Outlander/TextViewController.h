//
//  TextViewController.h
//  Outlander
//
//  Created by Joseph McBride on 1/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextTag.h"
#import "NSColor+Categories.h"

@interface TextViewController : NSViewController
@property (unsafe_unretained) IBOutlet NSTextView *TextView;

- (void)append:(TextTag*)text;
@end
