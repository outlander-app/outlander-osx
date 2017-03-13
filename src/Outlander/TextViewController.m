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
#import "MMScroller.h"
#import "Outlander-Swift.h"

@interface TextViewController () {
    NSDateFormatter *_dateFormatter;
    __weak IBOutlet NSScrollView *_scrollView;
}
@end

@implementation TextViewController

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self == nil) return nil;
    
    _keyup = [RACSubject subject];
    _command = [RACSubject subject];
    
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
    
    _TextView.commandSignal = [RACSubject subject];
    [_TextView.commandSignal subscribeNext:^(id x) {
        id<RACSubscriber> sub = (id<RACSubscriber>)_command;
        [sub sendNext:x];
    }];
    
    _TextView.closeWindowSignal = [RACSubject subject];
    [_TextView.closeWindowSignal subscribeNext:^(id x) {
        
        if ([self.key isEqualToString:@"main"]) {
            return;
        }
        
        id<RACSubscriber> sub = (id<RACSubscriber>)_command;
        
        CommandContext *ctx = [[CommandContext alloc] init];
        ctx.command = [NSString stringWithFormat:@"#window hide %@", self.key];
        [sub sendNext:ctx];
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

- (void)setBorderColor:(NSColor *)color {
    MyView *parent = (MyView *)[[self view] superview];
    if(parent != nil) {
        parent.borderColor = color;
        parent.needsDisplay = YES;
    }
}

- (NSColor *)borderColor {
    MyView *parent = (MyView *)[[self view] superview];
    if(parent != nil) {
        return parent.borderColor;
    }

    return [NSColor colorWithHexString:@"#cccccc"];
}

- (BOOL)showBorder {
    MyView *parent = (MyView *)[[self view] superview];
    
    if (parent != nil) {
        return parent.showBorder;
    }
    
    return self.lastShowBorder;
}

- (void)setShowBorder:(BOOL)show {
    _lastShowBorder = show;

    MyView *parent = (MyView *)[[self view] superview];
    if (parent != nil) {
        parent.showBorder = show;
        parent.needsDisplay = YES;
    }
}

- (NSRect)location {
    MyView *parent = (MyView *)[[self view] superview];
    if (parent != nil) {
        return parent.frame;
    }
    
    return self.lastLocation;
}

- (void)removeView {
    MyView *parent = (MyView *)[[self view] superview];
    [parent removeFromSuperview];
    
    [parent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _lastLocation = parent.frame;
    _lastShowBorder = parent.showBorder;
    
    _isVisible = NO;
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

- (void)setBackgroundColor:(NSColor *)color {
    _TextView.backgroundColor = color;
    MMScroller *vscroll = (MMScroller *)[_scrollView verticalScroller];
    MMScroller *hscroll = (MMScroller *)[_scrollView horizontalScroller];

    vscroll.backgroundColor = color;
    hscroll.backgroundColor = color;
}

- (NSColor *)backgroundColor {
    return _TextView.backgroundColor;
}

- (BOOL)endsWith:(NSString*)value {
    NSString *trimmed = [_TextView.string trimNewLine];
    return [trimmed hasSuffix:value];
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
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableAttributedString *target = [[NSMutableAttributedString alloc] initWithString:@""];
        
        BOOL timestamp = _TextView.displayTimestamp && (_TextView.textStorage.length == 0 || [self endsWithNewline:_TextView]);
        
        BOOL first = YES;
        
        for (TextTag *tag in tags) {
            
            if(tag.text == nil || tag.text.length == 0 || [self matchesGag:tag.text]) {
                continue;
            }
            
            if (first && timestamp) {
                [target appendAttributedString:[self stringFromTag:[self timestampTag]]];
                first = NO;
            }
            else if (_TextView.displayTimestamp && [self hasNewlineSuffix:target.string]) {
                [target appendAttributedString:[self stringFromTag:[self timestampTag]]];
            }
            
            tag.text = [self processSubs:tag.text];
            
            [target appendAttributedString:[self stringFromTag:tag]];
        }
    
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_TextView.textStorage setAttributedString:target];
        });
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

- (TextTag *)scriptTag:(TextTag *)tag {
    NSString *lines = tag.scriptLine > -1 ? [NSString stringWithFormat:@"(%d)", tag.scriptLine + 1] : @"";
    NSString *str = [NSString stringWithFormat:@"[%@%@]: ", tag.scriptName, lines];
    
    TextTag *newTag = [TextTag tagFor:str mono: YES];
    newTag.color = tag.color;
    newTag.backgroundColor = tag.backgroundColor;
    newTag.preset = tag.preset;
    
    return newTag;
}

- (NSAttributedString *)stringFromTag:(TextTag *)text {
    if(text.bold) {
//        text.color = @"#FFFF00";
        text.preset = @"creatures";
    }

    if( (text.color == nil || [text.color length] == 0) && [text.preset length] > 0 ) {
        ColorPreset *preset = [[self gameContext] presetFor:text.preset];
        text.color = preset.color;
        text.backgroundColor = preset.backgroundColor;
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
    
    if(text.color != nil && text.color.length > 0){
        color = [NSColor colorWithHexString:text.color];
    }
    else {
//        color = [NSColor colorWithHexString:@"#cccccc"];
        color = _fontColor;
    }
    
    [attr addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    if(text.backgroundColor != nil && text.backgroundColor.length > 0) {
        NSColor *backgroundColor = [NSColor colorWithHexString:text.backgroundColor];
        [attr addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
    }
    
    NSString *fontName = self.fontName;
    double fontSize = self.fontSize;
    if(text.mono){
        fontName = self.monoFontName;
        fontSize = self.monoFontSize;
    }
    [attr addAttribute:NSFontAttributeName value:[NSFont fontWithName:fontName size:fontSize] range:range];
    
    return attr;
}

- (void)append:(TextTag*)text toTextView:(MyNSTextView *) textView {
    if(text.text == nil || text.text.length == 0 || [self matchesGag:text.text]) {
        return;
    }
    
    text.text = [self processSubs:text.text];
    NSAttributedString *attr = [self stringFromTag:text];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL endswithNewline = [self endsWithNewline:textView];
        BOOL timestamp = textView.displayTimestamp && (textView.textStorage.length == 0 || endswithNewline);

        NSScroller *scroller = [[textView enclosingScrollView] verticalScroller];
        
        double autoScrollToleranceLineCount = 3.0;
        
        NSUInteger lines = [self countLines:[textView string]];
        double scrolled = [scroller doubleValue];
        double scrollDiff = 1.0 - scrolled;
        double percentScrolled = autoScrollToleranceLineCount / lines;
        
        BOOL shouldScrollToBottom = scrollDiff <= percentScrolled;
        
        if (timestamp) {
            [[textView textStorage] appendAttributedString:[self stringFromTag:[self timestampTag]]];
        }
        
        if ([text.scriptName length] > 0 &&  text.scriptLine > -1) {
            [[textView textStorage] appendAttributedString:[self stringFromTag:[self scriptTag:text]]];
        }

        NSLog(@"**** Should Scroll: (%@) %hhd, %f, %f", self.key, shouldScrollToBottom, scrollDiff, percentScrolled);
        
        NSLog(@"**** TS Length: (%@) %lu/%lu ****", self.key, lines, textView.textStorage.length);

        NSRange removeRange;
        BOOL shouldRemoveRange = NO;

        if (lines >= self.bufferSize) {
            shouldRemoveRange = YES;
            removeRange = [self getRemovalRange:textView.string withDiff:lines - self.bufferSize];
        }

//        [textView.textStorage beginEditing];

        if (shouldRemoveRange) {
            NSLog(@"**** Deleting [%lu,%lu] ****", removeRange.location, removeRange.length);
            [textView.textStorage deleteCharactersInRange:removeRange];
        }

        [textView.textStorage appendAttributedString:attr];
        
//        [textView.textStorage endEditing];

        if(shouldScrollToBottom) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
//                [textView scrollRangeToVisible:NSMakeRange([[textView string] length], 0)];
//            });
//            [self performSelector:@selector(scrollTextView:) withObject:textView afterDelay:0];
            NSArray *modes = [[NSArray alloc] initWithObjects:NSRunLoopCommonModes, nil];
            [self performSelector:@selector(scrollTextView:) withObject:textView afterDelay:0 inModes:modes];
        }
    });
}

- (void)scrollTextView:(MyNSTextView *)textView {
    [textView scrollRangeToVisible:NSMakeRange([[textView string] length], 0)];
}

- (NSRange)getRemovalRange:(NSString *)s withDiff:(NSUInteger) diff {

    NSUInteger totalLinesToRemove = diff + self.bufferClearSize;
    
    NSUInteger numberOfLines, index, stringLength = [s length];
    
    for (index = 0, numberOfLines = 0; index < stringLength;
         numberOfLines++) {
        index = NSMaxRange([s lineRangeForRange:NSMakeRange(index, 0)]);
        if (numberOfLines >= totalLinesToRemove) {
            break;
        }
    }
    
    return NSMakeRange(0, index);
}

- (NSUInteger) countLines:(NSString *)s {
    
    NSUInteger numberOfLines, index, stringLength = [s length];
    
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
                    
                    if (hl.backgroundColor != nil) {
                        [textStorage addAttribute:NSBackgroundColorAttributeName
                                            value:[NSColor colorWithHexString:hl.backgroundColor]
                                            range:newRange];
                    }
                }
            }
        }];
    }];
}

- (NSString *)processSubs:(NSString *)text {
    
    __block NSString *data = text;
    
    [_gameContext.substitutes enumerateObjectsUsingBlock:^(Substitute *sub, NSUInteger idx, BOOL *stop) {
        data = [data replaceWithPattern:sub.pattern andTemplate:sub.action];
    }];
    
    return data;
}

- (BOOL)matchesGag:(NSString *)text {
    __block BOOL matches = NO;
    
    [_gameContext.gags enumerateObjectsUsingBlock:^(Gag *gag, NSUInteger idx, BOOL *stop) {
        NSArray *matchGroups = [text matchesForPattern:gag.pattern];
        if(matchGroups && [matchGroups count] > 0) {
            *stop = YES;
            matches = YES;
            return;
        }
    }];
    
    return matches;
}

@end
