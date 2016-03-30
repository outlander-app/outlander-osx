//
//  MyNSTextView.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MyNSTextView.h"
#import "GameCommandRelay.h"
#import "CommandContext.h"

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

- (void)addMenuTitle:(NSString *)title {
    
    NSMenu *menu = [self menu];
    
    NSMenuItem *item = [menu itemWithTitle:self.menuTitle];
    
    if(item == nil) {
        item = [menu insertItemWithTitle:title action:nil keyEquivalent:@"" atIndex:0];
    }
    
    item.title = title;
    self.menuTitle = title;
}

- (IBAction)clearAction:(id)sender {
    [self setString:@""];
}

- (IBAction)toggleTimestamp:(id)sender {
    _displayTimestamp = !_displayTimestamp;
}

- (IBAction)closeWindow:(id)sender {
    id<RACSubscriber> sub = (id<RACSubscriber>)self.closeWindowSignal;
    [sub sendNext:nil];
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
    
    return YES;
}

- (void)clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    if([link hasPrefix:@"command:"]) {
        [self executeCommand:[link substringFromIndex:@"command:".length]];
    } else {
        [self openLink:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]];
    }
}

- (void)executeCommand:(NSString *)command {
    CommandContext *ctx = [[CommandContext alloc] init];
    ctx.command = command;
    
    id<RACSubscriber> sub = (id<RACSubscriber>)self.commandSignal;
    [sub sendNext:ctx];
}

- (void)openLink:(NSURLRequest *)request {
    NSString *scheme = [[request URL] scheme];
    if ([scheme hasPrefix:@"http"]) {
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    }
}

@end
