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
    
    _keyup = [RACSubject subject];
    
    return self;
}

- (void)awakeFromNib {
    _TextView.keyupSignal = [RACSubject subject];
    [_TextView.keyupSignal subscribeNext:^(id x) {
        id<RACSubscriber> sub = (id<RACSubscriber>)_keyup;
        [sub sendNext:x];
    }];
    
    [_TextView.textStorage setDelegate:self];
    [_TextView setLinkTextAttributes:@{
                                       NSForegroundColorAttributeName: [NSColor colorWithHexString:@"#cccccc"],
                                       NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle],
                                       NSCursorAttributeName: [NSCursor pointingHandCursor]
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

- (void)beginEdit {
    [_TextView.textStorage beginEditing];
}

- (void)endEdit {
    [_TextView.textStorage endEditing];
}

- (void)clear {
    [_TextView setString:@""];
}

- (void)append:(TextTag *)text {
    [self append:text toTextView:_TextView];
}

- (void)setWithTags:(NSArray *)tags {
    NSMutableAttributedString *target = [[NSMutableAttributedString alloc] initWithString:@""];
    
    for (TextTag *tag in tags){
        
        if(tag.text == nil || tag.text.length == 0) {
            continue;
        }
        
        [target appendAttributedString:[self stringFromTag:tag]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_TextView.textStorage setAttributedString:target];
    });
}

- (NSAttributedString *)stringFromTag:(TextTag *)text {
    if(text.bold) {
        text.color = @"#FFFF00";
    }

    NSString *escaped = [text.text replaceWithPattern:@"&gt;" andTemplate:@">"];
    escaped = [escaped replaceWithPattern:@"&lt;" andTemplate:@">"];
    
    NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:escaped];
    NSRange range = [[attr string] rangeOfString:escaped];

    if(text.href) {
        [attr addAttribute:NSLinkAttributeName value:text.href range:range];
    }
    
    NSColor *color = nil;
    
    if(text.color != nil && [text.color length] > 0){
        color = [NSColor colorWithHexString:text.color];
    }
    else {
        color = [NSColor colorWithHexString:@"#cccccc"];
    }
    
    [attr addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    if(text.backgroundColor != nil) {
        [attr addAttribute:NSBackgroundColorAttributeName value:text.backgroundColor range:range];
    }
    
    NSString *fontName = @"Helvetica";
    int fontSize = 14;
    if(text.mono){
        fontName = @"Menlo";
        fontSize = 13;
    }
    [attr addAttribute:NSFontAttributeName value:[NSFont fontWithName:fontName size:fontSize] range:range];
    
    return attr;
}

- (void)append:(TextTag*)text toTextView:(NSTextView *) textView {
    if(text.text == nil || text.text.length == 0) {
        return;
    }
    NSAttributedString *attr = [self stringFromTag:text];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSScroller *scroller = [[textView enclosingScrollView] verticalScroller];
        BOOL shouldScrollToBottom = [scroller doubleValue] == 1.0;
        
        [[textView textStorage] appendAttributedString:attr];
        
        if(shouldScrollToBottom) {
            [textView scrollRangeToVisible:NSMakeRange([[textView string] length], 0)];
        }
    });
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification {
    NSTextStorage *textStorage = [notification object];
    
    NSRange editedRange = textStorage.editedRange;
    NSString *data = [textStorage.string substringWithRange:editedRange];
    
    if(!data || data.length == 0) return;
    
    NSUInteger len = textStorage.length;
    
    [_gameContext.highlights enumerateObjectsUsingBlock:^(Highlight *hl, NSUInteger idx, BOOL *stop) {
    
        [[data matchesForPattern:hl.pattern] enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
            
            if(res.numberOfRanges > 0) {
                NSRange range = [res rangeAtIndex:0];
                NSRange newRange = NSMakeRange(range.location + editedRange.location, range.length);
                
                if(textStorage.string && textStorage.string.length >= len) {
                    [textStorage addAttribute:NSForegroundColorAttributeName
                                        value:[NSColor colorWithHexString:hl.color]
                                        range:newRange];
                }
            }
        }];
    }];
}

@end
