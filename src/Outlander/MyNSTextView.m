//
//  MyNSTextView.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MyNSTextView.h"

@interface MyNSTextView () {
}
@end

@implementation MyNSTextView

- (void)awakeFromNib {
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)keyUp:(NSEvent *)theEvent {
    id<RACSubscriber> sub = (id<RACSubscriber>)self.keyupSignal;
    [sub sendNext:theEvent];
}

@end
