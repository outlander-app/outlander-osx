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
#import "NSString+Files.h"
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
    
    _ViewContainer.backgroundColor = [NSColor redColor];
    _ViewContainer.draggable = NO;
    _ViewContainer.autoresizesSubviews = YES;
    
    TextViewController *mainController = [_ViewContainer addView:[NSColor blueColor] atLoc:NSMakeRect(0, 0, 600, 200)];
    [_windows setCacheObject:mainController forKey:@"main"];
    
    TextViewController *expController = [_ViewContainer addView:[NSColor blueColor] atLoc:NSMakeRect(_ViewContainer.frame.size.width, 0, 225, _ViewContainer.frame.size.height)];
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

//- (void)append:(TextTag*)text toTextView:(NSTextView *) textView {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSScroller *scroller = [[textView enclosingScrollView] verticalScroller];
//        BOOL shouldScrollToBottom = [scroller doubleValue] == 1.0;
//        
//        NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:[text text]];
//        NSRange range = [[attr string] rangeOfString:[text text]];
//        NSColor *color = [NSColor whiteColor];
//        
//        if(text.color != nil && [text.color length] > 0){
//            color = [NSColor colorWithHexString:text.color];
//        }
//        
//        [attr addAttribute:NSForegroundColorAttributeName value:color range:range];
//        NSString *fontName = @"Geneva";
//        if(text.mono){
//            fontName = @"Andale Mono";
//        }
//        [attr addAttribute:NSFontAttributeName value:[NSFont fontWithName:fontName size:12] range:range];
//        [[textView textStorage] appendAttributedString:attr];
//        
//        if(shouldScrollToBottom) {
//            [textView scrollRangeToVisible:NSMakeRange([[textView string] length], 0)];
//        }
//    });
//}

- (IBAction)connect:(id)sender {
    
    RACSignal *authSignal = [_server connectTo:@"eaccess.play.net" onPort:7900];
    
    [authSignal
     subscribeCompleted:^{
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

@end
