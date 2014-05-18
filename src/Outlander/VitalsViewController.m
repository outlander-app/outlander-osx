//
//  VitalsViewController.m
//  Outlander
//
//  Created by Joseph McBride on 2/3/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "VitalsViewController.h"
#import "TSMutableDictionary.h"
#import "MyProgressBar.h"
#import "NSView+Categories.h"
#import "NSColor+Categories.h"

@interface VitalsViewController ()
@end

@implementation VitalsViewController {
    TSMutableDictionary *_bars;
}

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self == nil) return nil;
    
    _bars = [[TSMutableDictionary alloc] initWithName:@"com.outlander.vitals"];
    
    return self;
}

-(void)awakeFromNib {
    self.backgroundView.backgroundColor = [NSColor blackColor];
    self.backgroundView.showBorder = NO;
    float height = self.view.frame.size.height;
    [self addBar:@"health" withFrame:NSMakeRect(0, 0, 150, height) text:@"Health 100%" color:[NSColor colorWithHexString:@"#cc0000"]];
    [self addBar:@"mana" withFrame:NSMakeRect(149, 0, 150, height) text:@"Mana 100%" color:[NSColor colorWithHexString:@"#00004B"]];
    [self addBar:@"stamina" withFrame:NSMakeRect(298, 0, 150, height) text:@"Stamina 100%" color:[NSColor colorWithHexString:@"#004000"]];
    [self addBar:@"concentration" withFrame:NSMakeRect(447, 0, 150, height) text:@"Concentration 100%" color:[NSColor colorWithHexString:@"#009999"]];
    [self addBar:@"spirit" withFrame:NSMakeRect(596, 0, 150, height) text:@"Spirit 100%" color:[NSColor colorWithHexString:@"#400040"]];
}

-(void)updateValue:(NSString *)key text:(NSString*)text value:(float)value {
    MyProgressBar *bar = [_bars cacheObjectForKey:key];
    bar.text = text;
    bar.value = value;
}

-(void)addBar:(NSString *)name withFrame:(NSRect)frame text:(NSString*)text color:(NSColor*)color {
    MyProgressBar *bar = [[MyProgressBar alloc] initWithFrame:frame];
    bar.text = text;
    bar.backgroundColor = color;
    [_bars setCacheObject:bar forKey:name];
    [self.view addSubview:bar];
    [bar fixLeftEdge:YES];
//    [bar fixWidth:NO];
}

@end
