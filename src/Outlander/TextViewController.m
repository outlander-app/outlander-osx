//
//  TextViewController.m
//  Outlander
//
//  Created by Joseph McBride on 1/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TextViewController.h"
#import "NSString+Categories.h"
#import "Highlight.h"

@interface TextViewController () {
}
@end

@implementation TextViewController

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self == nil) return nil;
    
    _keyup = [RACReplaySubject subject];
    
    return self;
}

- (void)awakeFromNib {
    _TextView.keyupSignal = [RACReplaySubject subject];
    [_TextView.keyupSignal subscribeNext:^(id x) {
        id<RACSubscriber> sub = (id<RACSubscriber>)_keyup;
        [sub sendNext:x];
    }];
}

- (NSString *)text {
    return _TextView.string;
}

- (BOOL)endsWith:(NSString*)value {
    NSString *trimmed = [_TextView.string trimNewLine];
    NSString *val = [[trimmed substringFromIndex:trimmed.length - 2] trimNewLine];
    return [val isEqualToString:value];
}

- (void)clear {
    [_TextView setString:@""];
}

- (void)append:(TextTag *)text {
    [self append:text toTextView:_TextView];
}

- (void)append:(TextTag*)text toTextView:(NSTextView *) textView {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSScroller *scroller = [[textView enclosingScrollView] verticalScroller];
        BOOL shouldScrollToBottom = [scroller doubleValue] == 1.0;
        
        NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:[text text]];
        NSRange range = [[attr string] rangeOfString:text.text];
        
        NSColor *color = nil;
        
        if(text.color != nil && [text.color length] > 0){
            color = [NSColor colorWithHexString:text.color];
        }
        else {
            color = [NSColor colorWithHexString:@"#cccccc"];
        }
        
        [attr addAttribute:NSForegroundColorAttributeName value:color range:range];
        NSString *fontName = @"Verdana";
        int fontSize = 12;
        if(text.mono){
            fontName = @"Courier New";
            fontSize = 13;
        }
        [attr addAttribute:NSFontAttributeName value:[NSFont fontWithName:fontName size:fontSize] range:range];
        [[textView textStorage] appendAttributedString:attr];
        
        if(shouldScrollToBottom) {
            [textView scrollRangeToVisible:NSMakeRange([[textView string] length], 0)];
        }
        
        [self updateHighlights:text.text];
    });
}

- (void)updateHighlights:(NSString *)data {
    if(!_gameContext) return;
    
    NSUInteger len = self.TextView.string.length;
    NSUInteger startOfString = len - data.length;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        [_gameContext.highlights enumerateObjectsUsingBlock:^(Highlight *hl, NSUInteger idx, BOOL *stop) {
            
            [[[self matchesFor:data pattern:hl.pattern].rac_sequence filter:^BOOL(NSTextCheckingResult *value) {
                return value.numberOfRanges > 0;
            }].signal subscribeNext:^(NSTextCheckingResult *x) {
                NSRange range = [x rangeAtIndex:0];
                NSRange newRange = NSMakeRange(range.location + startOfString, range.length);
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [[_TextView textStorage] addAttribute:NSForegroundColorAttributeName
                                                    value:[NSColor colorWithHexString:hl.color]
                                                    range:newRange];
                });
            }];
        }];
    });
}

- (NSArray *)matchesFor:(NSString *)data pattern:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    if(error) {
        NSLog(@"matchesFor Error: %@", [error localizedDescription]);
        return nil;
    }
    
    NSArray *matches = [regex matchesInString:data options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [data length])];
    return matches;
}

@end
