//
//  TextViewController.h
//  Outlander
//
//  Created by Joseph McBride on 1/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TextTag.h"
#import "NSColor+Categories.h"

@interface TextViewController : NSViewController
@property (nonatomic, copy) NSString *key;
@property (unsafe_unretained) IBOutlet NSTextView *TextView;

- (NSString *)text;
- (void)clear;
- (BOOL)endsWith:(NSString*)value;
- (void)append:(TextTag*)text;
@end
