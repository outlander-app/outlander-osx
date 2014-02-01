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
    
    TextViewController *mainController = [_ViewContainer addView:[NSColor blackColor]
                                                           atLoc:NSMakeRect(0, 0, 600, _ViewContainer.frame.size.height)];
    [_windows setCacheObject:mainController forKey:@"main"];
    
    TextViewController *arrivalsController = [_ViewContainer addView:[NSColor blackColor]
                                                               atLoc:NSMakeRect(_ViewContainer.frame.size.width, _ViewContainer.frame.size.height, 300, 200)];
    [_windows setCacheObject:arrivalsController forKey:@"arrivals"];
    
    TextViewController *expController = [_ViewContainer addView:[NSColor blackColor]
                                                          atLoc:NSMakeRect(_ViewContainer.frame.size.width, 0, 300, _ViewContainer.frame.size.height)];
    [_windows setCacheObject:expController forKey:@"exp"];
}

- (IBAction)commandSubmit:(NSTextField*)sender {
    NSString *command = [sender stringValue];
    if([command length] == 0) return;
    
    if(_gameStream != nil) {
        [_gameStream sendCommand:command];
    }
    [sender setStringValue:@""];
    NSString *prompt = [_gameStream.globalVars cacheObjectForKey:@"prompt"];
    TextTag *tag = [TextTag tagFor:[NSString stringWithFormat:@"%@%@\n", prompt, command] mono:NO];
    [self append:tag to:@"main"];
}

- (void)append:(TextTag*)text to:(NSString *)key {
    TextViewController *controller = [_windows cacheObjectForKey:key];
    [controller append:text];
}

- (IBAction)connect:(id)sender {
    
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
    
    [_gameStream.connected subscribeNext:^(NSString *message) {
         NSString *dateFormat =[@"%@" stringFromDateFormat:@"HH:mm"];
        [self append:[TextTag tagFor:[NSString stringWithFormat:@"[%@ %@]\n", dateFormat, message]
                                mono:true]
                  to:@"main"];
    }];
    
    [_gameStream.thoughts subscribeNext:^(TextTag *tag) {
        NSString *timeStamp = [@"%@" stringFromDateFormat:@"HH:mm"];
        tag.text = [NSString stringWithFormat:@"[%@]%@\n", timeStamp, tag.text];
//        [self append:tag to:@"thoughts"];
    }];
    
    [_gameStream.arrivals subscribeNext:^(TextTag *tag) {
        NSString *timeStamp = [@"%@" stringFromDateFormat:@"HH:mm"];
        tag.text = [NSString stringWithFormat:@"[%@]%@\n", timeStamp, tag.text];
        [self append:tag to:@"arrivals"];
    }];
    
    [_gameStream.deaths subscribeNext:^(TextTag *tag) {
        NSString *timeStamp = [@"%@" stringFromDateFormat:@"HH:mm"];
        tag.text = [NSString stringWithFormat:@"[%@]%@\n", timeStamp, tag.text];
        //[self append:tag to:@"deaths"];
    }];
}

@end
