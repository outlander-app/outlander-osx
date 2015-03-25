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
    
    NSMenu *menu = [self menu];
    
    NSMenuItem *clearItem = [menu itemWithTitle:@"Clear"];
    if(clearItem == nil) {
        [menu insertItem:[NSMenuItem separatorItem] atIndex:0];
        
        [menu insertItemWithTitle:@"Close Window" action:@selector(closeWindow:) keyEquivalent:@"" atIndex:0];
        [menu insertItemWithTitle:@"Timestamp" action:@selector(toggleTimestamp:) keyEquivalent:@"" atIndex:0];
        [menu insertItemWithTitle:@"Clear" action:@selector(clearAction:) keyEquivalent:@"" atIndex:0];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)keyUp:(NSEvent *)theEvent {
    id<RACSubscriber> sub = (id<RACSubscriber>)self.keyupSignal;
    [sub sendNext:theEvent];
}

- (IBAction)clearAction:(id)sender {
    [self setString:@""];
}

- (IBAction)toggleTimestamp:(id)sender {
    _displayTimestamp = !_displayTimestamp;
}

- (IBAction)closeWindow:(id)sender {
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
    if ([item action] == @selector(toggleTimestamp:)) {
        NSMenuItem *menuItem = (NSMenuItem *)item;
        if(_displayTimestamp) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }
    
    if ([item action] == @selector(closeWindow:)) {
        return NO;
    }
    
    return YES;
}

//- (void)clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
//    NSLog(@"Clicked on link %@ %lu", link, (unsigned long)charIndex);
//}

@end
