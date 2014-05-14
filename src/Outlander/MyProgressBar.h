//
//  MyProgressBar.h
//  Outlander
//
//  Created by Joseph McBride on 2/3/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface MyProgressBar : NSView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) float value;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *foregroundColor;
@property (nonatomic, strong) NSFont *font;

@end
