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
    self.view.autoresizesSubviews = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameChanged:) name:NSViewFrameDidChangeNotification object:self.view];
    
    float height = self.view.frame.size.height;
    float width = self.view.frame.size.width / 5.0;
    float viewX = 0.0;
    
    [self addBar:@"health" withFrame:NSMakeRect(viewX, 0, width, height) text:@"Health 100%" color:[NSColor colorWithHexString:@"#cc0000"]];
    viewX = viewX + width;
    [self addBar:@"mana" withFrame:NSMakeRect(viewX, 0, width, height) text:@"Mana 100%" color:[NSColor colorWithHexString:@"#00004B"]];
    viewX = viewX + width;
    [self addBar:@"stamina" withFrame:NSMakeRect(viewX, 0, width, height) text:@"Stamina 100%" color:[NSColor colorWithHexString:@"#004000"]];
    viewX = viewX + width;
    [self addBar:@"concentration" withFrame:NSMakeRect(viewX, 0, width, height) text:@"Concentration 100%" color:[NSColor colorWithHexString:@"#009999"]];
    viewX = viewX + width;
    [self addBar:@"spirit" withFrame:NSMakeRect(viewX, 0, width, height) text:@"Spirit 100%" color:[NSColor colorWithHexString:@"#400040"]];
}

-(void)frameChanged:(NSNotification *)notification {
    __block float viewX = 0.0;
    float width = self.view.frame.size.width / self.view.subviews.count;
    [self.view.subviews enumerateObjectsUsingBlock:^(NSView *view, NSUInteger idx, BOOL *stop) {
        [view setFrame:NSMakeRect(viewX, view.frame.origin.y, width, view.frame.size.height)];
        viewX = viewX + width;
    }];
}

-(void)updateColor:(NSString *)key foreground:(NSString *)foregroundColor background:(NSString *) backgroundColor {
    MyProgressBar *bar = [_bars cacheObjectForKey:key];
    bar.foregroundColor = [NSColor colorWithHexString:foregroundColor];
    bar.backgroundColor = [NSColor colorWithHexString:backgroundColor];
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
}

@end
