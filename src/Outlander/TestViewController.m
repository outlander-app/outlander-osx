//
//  TestViewController.m
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TestViewController.h"
#import "HTMLNode.h"
#import "HTMLParser.h"
#import "TextTag.h"
#import "NSString+Categories.h"
#import "NSColor+Categories.h"
#import "MyView.h"
#import "NSView+Categories.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self == nil) return nil;
    
    _windows = [[TSMutableDictionary alloc] initWithName:@"gamewindows"];
    _server = [[AuthenticationServer alloc]init];
    _gameStream = [[GameStream alloc] init];
    
    return self;
}

- (void)awakeFromNib {
    _ViewContainer.backgroundColor = [NSColor blackColor];
    _ViewContainer.draggable = NO;
    _ViewContainer.autoresizesSubviews = YES;
    [_ViewContainer listenBoundsChanges];
    
    [self addWindow:@"main"
           withRect:NSMakeRect(0, 100, 611, 377)];
    
    [self addWindow:@"thoughts"
           withRect:NSMakeRect(0, 0, 361, 101)];
    
    [self addWindow:@"arrivals"
           withRect:NSMakeRect(360, 0, 251, 101)];
    
    [self addWindow:@"deaths"
           withRect:NSMakeRect(_ViewContainer.frame.size.width, 0, 250, 101)];
    
    [self addWindow:@"room"
           withRect:NSMakeRect(_ViewContainer.frame.size.width, 100, 250, 177)];
    
    [self addWindow:@"exp"
           withRect:NSMakeRect(_ViewContainer.frame.size.width, 276, 250, 201)];
}

- (void)addWindow:(NSString *)key withRect:(NSRect)rect {
    
    TextViewController *expController = [_ViewContainer addView:[NSColor blackColor]
                                                          atLoc:rect];
    [_windows setCacheObject:expController forKey:key];
}

- (IBAction)commandSubmit:(NSTextField*)sender {
    NSString *command = [sender stringValue];
    if([command length] == 0) return;
    
    if(_gameStream != nil) {
        [_gameStream sendCommand:command];
    }
    [sender setStringValue:@""];
    NSString *prompt = [_gameStream.globalVars cacheObjectForKey:@"prompt"];
    TextTag *tag = [TextTag tagFor:[NSString stringWithFormat:@"%@ %@\n", prompt, command] mono:NO];
    [self append:tag to:@"main"];
}

- (void)clear:(NSString*)key{
    TextViewController *controller = [_windows cacheObjectForKey:key];
    [controller clear];
}

- (void)append:(TextTag*)text to:(NSString *)key {
    NSString *prompt = [_gameStream.globalVars cacheObjectForKey:@"prompt"];
    
    TextViewController *controller = [_windows cacheObjectForKey:key];
    
    if([[text.text trim] isEqualToString:prompt]) {
        if(![controller endsWith:prompt]){
            [controller append:text];
        }
    }
    else {
        [controller append:text];
    }
}

- (IBAction)connect:(id)sender {
    
    [_gameStream.connected subscribeNext:^(NSString *message) {
        NSString *dateFormat =[@"%@" stringFromDateFormat:@"HH:mm"];
        [self append:[TextTag tagFor:[NSString stringWithFormat:@"[%@ %@]\n", dateFormat, message]
                                mono:true]
                  to:@"main"];
    }];
    
    [_gameStream.thoughts subscribeNext:^(TextTag *tag) {
        NSString *timeStamp = [@"%@" stringFromDateFormat:@"HH:mm"];
        tag.text = [NSString stringWithFormat:@"[%@]: %@\n", timeStamp, tag.text];
        [self append:tag to:@"thoughts"];
    }];
    
    [_gameStream.arrivals subscribeNext:^(TextTag *tag) {
        NSString *timeStamp = [@"%@" stringFromDateFormat:@"HH:mm"];
        tag.text = [NSString stringWithFormat:@"[%@]:%@\n", timeStamp, tag.text];
        [self append:tag to:@"arrivals"];
    }];
    
    [_gameStream.deaths subscribeNext:^(TextTag *tag) {
        NSString *timeStamp = [@"%@" stringFromDateFormat:@"HH:mm"];
        tag.text = [NSString stringWithFormat:@"[%@]:%@\n", timeStamp, tag.text];
        [self append:tag to:@"deaths"];
    }];
    
    [_gameStream.room subscribeNext:^(id x) {
        [self updateRoom];
    }];
    
    [_gameStream.vitals subscribeNext:^(id x) {
        [self updateVitals];
    }];
    
    RACSignal *authSignal = [_server connectTo:@"eaccess.play.net" onPort:7900];
    
    [authSignal
     subscribeNext:^(id x) {
         NSString *dateFormat =[@"%@" stringFromDateFormat:@"HH:mm"];
        [self append:[TextTag tagFor:[NSString stringWithFormat:@"[%@ %@]\n", dateFormat, x]
                                mono:true]
                  to:@"main"];
     }
     error:^(NSError *error) {
         NSString *dateFormat =[@"%@" stringFromDateFormat:@"HH:mm"];
         NSString *msg = [error.userInfo objectForKey:@"message"];
        [self append:[TextTag tagFor:[NSString stringWithFormat:@"[%@ %@]\n", dateFormat, msg]
                                mono:true]
                  to:@"main"];
     }
     completed:^{
        [self append:[TextTag tagFor:[@"[%@ disconnected]\n" stringFromDateFormat:@"HH:mm"]
                                mono:true]
                  to:@"main"];
    }];
    
    [[[_server
       authenticate:@"" password:@"" game:@"DR" character:@""]
    flattenMap:^RACStream *(GameConnection *connection) {
        NSLog(@"Connection: %@", connection);
        return [_gameStream connect:connection];
    }]
    subscribeNext:^(NSArray *tags) {
        
        _viewModel.righthand = [NSString stringWithFormat:@"R: %@", [_gameStream.globalVars cacheObjectForKey:@"righthand"]];
        _viewModel.lefthand = [NSString stringWithFormat:@"L: %@", [_gameStream.globalVars cacheObjectForKey:@"lefthand"]];
        _viewModel.spell = [NSString stringWithFormat:@"S: %@", [_gameStream.globalVars cacheObjectForKey:@"spell"]];
        
        for (TextTag *tag in tags) {
            [self append:tag to:@"main"];
        }
    } completed:^{
        [self append:[TextTag tagFor:[@"[%@ disconnected]\n" stringFromDateFormat:@"HH:mm"]
                                mono:true]
                  to:@"main"];
    }];
}

-(void)updateRoom {
    NSString *name = [_gameStream.globalVars cacheObjectForKey:@"roomtitle"];
    NSString *desc = [_gameStream.globalVars cacheObjectForKey:@"roomdesc"];
    NSString *objects = [_gameStream.globalVars cacheObjectForKey:@"roomobjs"];
    NSString *exits = [_gameStream.globalVars cacheObjectForKey:@"roomexits"];
    NSString *players = [_gameStream.globalVars cacheObjectForKey:@"roomplayers"];
    
    [self clear:@"room"];
    
    NSMutableString *room = [[NSMutableString alloc] init];
    if(name != nil && name.length != 0) {
        TextTag *nameTag = [TextTag tagFor:name mono:false];
        nameTag.color = @"#0000FF";
        [self append:nameTag to:@"room"];
        [room appendString:@"\n"];
    }
    if(desc != nil && desc.length != 0)
        [room appendFormat:@"%@\n", desc];
    if(objects != nil && objects.length != 0)
        [room appendFormat:@"%@\n", objects];
    if(exits != nil && exits.length != 0)
        [room appendFormat:@"%@\n", exits];
    if(players != nil && players.length != 0)
        [room appendFormat:@"%@\n", players];
    
    
    TextTag *tag = [TextTag tagFor:room mono:false];
    [self append:tag to:@"room"];
}

-(void)updateVitals {
}

@end
