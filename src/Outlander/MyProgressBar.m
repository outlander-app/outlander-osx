//
//  MyProgressBar.m
//  Outlander
//
//  Created by Joseph McBride on 2/3/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MyProgressBar.h"
#import "NSColor+Categories.h"

@implementation MyProgressBar

-(id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self == nil) return nil;
   
    self.text = @"Something 100%";
    self.value = 100;
    self.backgroundColor = [NSColor colorWithHexString:@"#00004B"];
    self.foregroundColor = [NSColor colorWithHexString:@"#F5F5F5"];
    self.font = [NSFont fontWithName:@"Menlo Bold" size:11];

    [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"foregroundColor" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew context:nil];
    
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.needsDisplay = YES;
}

-(BOOL)isFlipped {
    return YES;
}

-(void)drawRect:(NSRect)dirtyRect {
    
    float height = self.frame.size.height;
    float width = self.frame.size.width;
    float calcValue = width * (self.value * 0.01);
    float strokeWidth = 0.0;
    
    [[NSColor colorWithHexString:@"#999999"] setFill];
    NSRectFill(NSMakeRect(0, 0, width, height));

//    [[NSColor whiteColor] setStroke];
//    
//    NSBezierPath* thePath = [NSBezierPath bezierPath];
//    [thePath appendBezierPathWithRect:self.bounds];
//    [thePath setLineWidth:strokeWidth];
//    [thePath setLineCapStyle:NSRoundLineCapStyle];
//    [thePath stroke];
    
    [self.backgroundColor setFill];
    NSRectFill(NSMakeRect(strokeWidth, strokeWidth, calcValue-(strokeWidth * 2), height - (strokeWidth * 2)));
    
	[super drawRect:self.bounds];
    
    NSTextStorage *storage = [[NSTextStorage alloc] init];
    
    NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:self.text];
    NSRange range = [[attr string] rangeOfString:self.text];
   
    [attr addAttribute:NSFontAttributeName value:self.font range:range];
    [attr addAttribute:NSForegroundColorAttributeName value:self.foregroundColor range:range];
    
    [storage setAttributedString:attr];
    
    [storage drawAtPoint:NSMakePoint((self.frame.size.width / 2.0) - (attr.size.width / 2.0), (self.frame.size.height / 2.0) - (attr.size.height / 2.0))];
}

@end
