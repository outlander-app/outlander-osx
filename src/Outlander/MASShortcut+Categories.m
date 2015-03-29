//
//  MASShortcut+Categories.m
//  Outlander
//
//  Created by Joseph McBride on 3/29/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

#import "MASShortcut+Categories.h"

@implementation MASShortcut (Categories)

- (NSString *) olDescription {
    return [NSString stringWithFormat:@"%@%@", self.modifierFlagsString, self.olKeyCodeString];
}

- (NSString *) olKeyCodeString {
    switch (self.keyCode) {
        // Keypad
        case kVK_ANSI_Keypad0: return @"Keypad0";
        case kVK_ANSI_Keypad1: return @"Keypad1";
        case kVK_ANSI_Keypad2: return @"Keypad2";
        case kVK_ANSI_Keypad3: return @"Keypad3";
        case kVK_ANSI_Keypad4: return @"Keypad4";
        case kVK_ANSI_Keypad5: return @"Keypad5";
        case kVK_ANSI_Keypad6: return @"Keypad6";
        case kVK_ANSI_Keypad7: return @"Keypad7";
        case kVK_ANSI_Keypad8: return @"Keypad8";
        case kVK_ANSI_Keypad9: return @"Keypad9";
        case kVK_ANSI_KeypadDecimal: return @"KeypadDecimal";
        case kVK_ANSI_KeypadMultiply: return @"KeypadMultiply";
        case kVK_ANSI_KeypadPlus: return @"KeypadPlus";
        case kVK_ANSI_KeypadClear: return @"KeypadClear";
        case kVK_ANSI_KeypadDivide: return @"KeypadDivide";
        case kVK_ANSI_KeypadEnter: return @"KeypadEnter";
        case kVK_ANSI_KeypadMinus: return @"KeypadMinus";
        case kVK_ANSI_KeypadEquals: return @"KeypadEquals";
    }
    
    return [self keyCodeString];
}

@end
