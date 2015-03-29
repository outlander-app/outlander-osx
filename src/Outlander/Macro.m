//
//  Macro.m
//  Outlander
//
//  Created by Joseph McBride on 6/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Macro.h"
#import "NSString+Categories.h"

@interface Macro () {
}
@end

@implementation Macro

-(instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    
    _keyCode = -1;
    
    return self;
}

-(void)setKeys:(NSString *)keys {
    //NSArray *items = [keys componentsSeparatedByString:@","];
    
    __block NSString *strKeyCode = @"";
    __block NSUInteger modifiers = 0;
    
    NSString *pattern = @"^([⌃⌥⌘⇧]+)?(.*)$";
    [[keys matchesForPattern:pattern] enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
        if(res.numberOfRanges > 1) {
            if([res rangeAtIndex:1].location != NSNotFound) {
                NSString *strModifers = [keys substringWithRange:[res rangeAtIndex:1]];
                modifiers = [Macro stringToFlags:strModifers];
            }
            strKeyCode = [keys substringWithRange:[res rangeAtIndex:2]];
        }
    }];
    
    self.keyCode = strKeyCode.length > 0 ? [strKeyCode integerValue] : -1;
    self.modifiers = modifiers;
    _keys = keys;
}

- (NSString *)modifierFlagsString {
    unichar chars[4];
    NSUInteger count = 0;
    // These are in the same order as the menu manager shows them
    if (self.modifiers & NSControlKeyMask) chars[count++] = kControlUnicode;
    if (self.modifiers & NSAlternateKeyMask) chars[count++] = kOptionUnicode;
    if (self.modifiers & NSShiftKeyMask) chars[count++] = kShiftUnicode;
    if (self.modifiers & NSCommandKeyMask) chars[count++] = kCommandUnicode;
    return (count ? [NSString stringWithCharacters:chars length:count] : @"");
}

+(NSUInteger)stringToFlags:(NSString *)flags {
    
    NSDictionary *lookup =
        @{  @"⌥": [NSNumber numberWithInteger:NSAlternateKeyMask],
            @"⌃": [NSNumber numberWithInteger:NSControlKeyMask],
            @"⌘": [NSNumber numberWithInteger:NSCommandKeyMask],
            @"⇧": [NSNumber numberWithInteger:NSShiftKeyMask]
        };
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [flags length]; i++) {
        NSString *ch = [flags substringWithRange:NSMakeRange(i, 1)];
        [array addObject:ch];
    }
    
    __block NSUInteger modifers =  0;
    
    [array enumerateObjectsUsingBlock:^(NSString *flag, NSUInteger idx, BOOL *stop) {
        if ([lookup objectForKey:flag] != nil) {
            NSNumber *number = [lookup objectForKey:flag];
            modifers |= [number unsignedLongValue];
        }
    }];
    
    return modifers;
}

@end
