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
#import "MyView.h"
#import "Outlander-Swift.h"

@interface TextViewController () {
    NSDateFormatter *_dateFormatter;
    BOOL _displayBorder;
}
@end

@implementation TextViewController

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self == nil) return nil;
    
    _keyup = [RACSubject subject];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"HH:mm"];
    
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
    
    [_TextView setSelectedTextAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSColor colorWithHexString:@"#252729"], NSBackgroundColorAttributeName,
            [NSColor colorWithHexString:@"#cccccc"], NSForegroundColorAttributeName,
        nil]];
    
    NSMenu *menu = _TextView.menu;
    NSMenuItem *item = [menu itemWithTitle:@"Show Border"];
    if(item == nil) {
        [menu insertItemWithTitle:@"Show Border" action:@selector(toggleShowBorder:) keyEquivalent:@"" atIndex:2];
    }
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
    if ([item action] == @selector(toggleShowBorder:)) {
        NSMenuItem *menuItem = (NSMenuItem *)item;
        MyView *parent = (MyView *)[[self view] superview];
        if(parent.showBorder) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }
    
    return YES;
}

- (void)toggleShowBorder:(id)sender {
    MyView *parent = (MyView *)[[self view] superview];
    parent.showBorder = !parent.showBorder;
    parent.needsDisplay = YES;
}

- (BOOL)showBorder {
    MyView *parent = (MyView *)[[self view] superview];
    return parent.showBorder;
}

- (void)setShowBorder:(BOOL)show {
    MyView *parent = (MyView *)[[self view] superview];
    parent.showBorder = show;
    parent.needsDisplay = YES;
}

- (BOOL)displayTimestamp {
    return _TextView.displayTimestamp;
}

- (void)setDisplayTimestamp:(BOOL)timestamp {
    _TextView.displayTimestamp = timestamp;
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
    
    BOOL timestamp = _TextView.displayTimestamp && (_TextView.textStorage.length == 0 || [self endsWithNewline:_TextView]);
    
    
    BOOL first = YES;
    
    for (TextTag *tag in tags) {
        
        if(tag.text == nil || tag.text.length == 0) {
            continue;
        }
        
        if (first && timestamp) {
            [target appendAttributedString:[self stringFromTag:[self timestampTag]]];
            first = NO;
        }
        else if (_TextView.displayTimestamp && [self hasNewlineSuffix:target.string]) {
            [target appendAttributedString:[self stringFromTag:[self timestampTag]]];
        }
        
        [target appendAttributedString:[self stringFromTag:tag]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_TextView.textStorage setAttributedString:target];
    });
}

- (BOOL)endsWithNewline:(NSTextView *)textView {
    NSString *str = textView.textStorage.string;
    return [self hasNewlineSuffix:str];
}

- (BOOL)hasNewlineSuffix:(NSString *)str {
    NSRange r = [str rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
                                      options:NSBackwardsSearch];
    BOOL foundChar = r.location != NSNotFound;
    BOOL isLineFinal = foundChar && (r.location + r.length == [str length]);
    return isLineFinal;
}

- (TextTag *)timestampTag {
    NSString *str = [NSString stringWithFormat:@"[%@] ", [_dateFormatter stringFromDate:[NSDate date]]];
    return [TextTag tagFor:str mono: YES];
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
    
    if(text.command) {
        [attr addAttribute:NSLinkAttributeName value:[NSString stringWithFormat:@"command:%@", text.command] range:range];
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

- (void)append:(TextTag*)text toTextView:(MyNSTextView *) textView {
    if(text.text == nil || text.text.length == 0) {
        return;
    }
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL endswithNewline = [self endsWithNewline:textView];
        BOOL timestamp = textView.displayTimestamp && (textView.textStorage.length == 0 || endswithNewline);
        
        NSAttributedString *attr = [self stringFromTag:text];
       
        NSScroller *scroller = [[textView enclosingScrollView] verticalScroller];
        
        double autoScrollToleranceLineCount = 3.0;
        
        unsigned long lines = [self countLines:[textView string]];
        double scrolled = [scroller doubleValue];
        double scrollDiff = 1.0 - scrolled;
        double percentScrolled = autoScrollToleranceLineCount / lines;
        
        BOOL shouldScrollToBottom = scrollDiff <= percentScrolled;
        
        if (timestamp) {
            [[textView textStorage] appendAttributedString:[self stringFromTag:[self timestampTag]]];
        }
        
        [[textView textStorage] appendAttributedString:attr];
        
        if(shouldScrollToBottom) {
            [textView scrollRangeToVisible:NSMakeRange([[textView string] length], 0)];
        }
    });
}

- (unsigned long)countLines:(NSString *)s {
    
    unsigned long numberOfLines, index, stringLength = [s length];
    
    for (index = 0, numberOfLines = 0; index < stringLength;
         numberOfLines++) {
        index = NSMaxRange([s lineRangeForRange:NSMakeRange(index, 0)]);
    }
    return numberOfLines;
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
