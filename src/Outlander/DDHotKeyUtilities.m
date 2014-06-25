/*
 DDHotKey -- DDHotKeyUtilities.m
 
 Copyright (c) Dave DeLong <http://www.davedelong.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the author(s) or copyright holder(s) be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "DDHotKeyUtilities.h"
#import <Carbon/Carbon.h>

static NSDictionary *DDKeyCodeToCharacterMap(void) {
    static NSDictionary *keyCodeMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyCodeMap = @{
                       @(kVK_Return) : @"↩",
                       @(kVK_Tab) : @"⇥",
                       @(kVK_Space) : @"⎵",
                       @(kVK_Delete) : @"⌫",
                       @(kVK_Escape) : @"⎋",
                       @(kVK_Command) : @"⌘",
                       @(kVK_Shift) : @"⇧",
                       @(kVK_CapsLock) : @"⇪",
                       @(kVK_Option) : @"⌥",
                       @(kVK_Control) : @"⌃",
                       @(kVK_RightShift) : @"⇧",
                       @(kVK_RightOption) : @"⌥",
                       @(kVK_RightControl) : @"⌃",
                       @(kVK_VolumeUp) : @"🔊",
                       @(kVK_VolumeDown) : @"🔈",
                       @(kVK_Mute) : @"🔇",
                       @(kVK_Function) : @"\u2318",
                       @(kVK_F1) : @"F1",
                       @(kVK_F2) : @"F2",
                       @(kVK_F3) : @"F3",
                       @(kVK_F4) : @"F4",
                       @(kVK_F5) : @"F5",
                       @(kVK_F6) : @"F6",
                       @(kVK_F7) : @"F7",
                       @(kVK_F8) : @"F8",
                       @(kVK_F9) : @"F9",
                       @(kVK_F10) : @"F10",
                       @(kVK_F11) : @"F11",
                       @(kVK_F12) : @"F12",
                       @(kVK_F13) : @"F13",
                       @(kVK_F14) : @"F14",
                       @(kVK_F15) : @"F15",
                       @(kVK_F16) : @"F16",
                       @(kVK_F17) : @"F17",
                       @(kVK_F18) : @"F18",
                       @(kVK_F19) : @"F19",
                       @(kVK_F20) : @"F20",
                       //                       @(kVK_Help) : @"",
                       @(kVK_ForwardDelete) : @"⌦",
                       @(kVK_Home) : @"↖",
                       @(kVK_End) : @"↘",
                       @(kVK_PageUp) : @"⇞",
                       @(kVK_PageDown) : @"⇟",
                       @(kVK_LeftArrow) : @"←",
                       @(kVK_RightArrow) : @"→",
                       @(kVK_DownArrow) : @"↓",
                       @(kVK_UpArrow) : @"↑",
                       
                       @(kVK_ANSI_A) : @"A",
                       @(kVK_ANSI_B) : @"B",
                       };
    });
    return keyCodeMap;
}


DDKeyCodes DDKeyCodesFromString(NSString *keys) {
    NSDictionary *characterMap = DDKeyCodeToCharacterMap();
    
    __block unsigned short keyCode = 0;
    __block NSArray *modifierChars = @[characterMap[@(kVK_Control)], characterMap[@(kVK_Option)], characterMap[@(kVK_Shift)], characterMap[@(kVK_Command)]];
    __block NSMutableString *str = [[NSMutableString alloc] init];
    __block NSUInteger mods = 0;
    __block NSUInteger offset = 0;
    NSUInteger keyStart = 0;
    NSRange keyRange;

    for (NSUInteger i=0; i<keys.length; i++) {
        if(i+1 >= keys.length) break;
        
        keyRange = NSMakeRange(offset, i+1);
        [str setString:[keys substringWithRange:keyRange]];
        if([modifierChars containsObject:str]) {
            keyStart++;
            offset++;
            
            if([str isEqualToString:characterMap[@(kVK_Control)]]) {
                mods = mods | NSControlKeyMask;
            }
            if([str isEqualToString:characterMap[@(kVK_Option)]]) {
                mods = mods | NSAlternateKeyMask;
            }
            if([str isEqualToString:characterMap[@(kVK_Shift)]]) {
                mods = mods | NSShiftKeyMask;
            }
            if([str isEqualToString:characterMap[@(kVK_Command)]]) {
                mods = mods | NSCommandKeyMask;
            }
        }
    }
   
    [str setString:[keys substringWithRange:NSMakeRange(keyStart, keys.length-keyStart)]];
    [characterMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL *stop) {
        if([obj isEqualToString:str]) {
            keyCode = key.shortValue;
            *stop = YES;
        }
    }];
    
    DDKeyCodes result = DDMakeKeyCodes(keyCode, mods);
    return result;
}

NSString *DDStringFromKeyCode(unsigned short keyCode, NSUInteger modifiers) {
    NSMutableString *final = [NSMutableString stringWithString:@""];
    NSDictionary *characterMap = DDKeyCodeToCharacterMap();
    
    if (modifiers & NSControlKeyMask) {
        [final appendString:[characterMap objectForKey:@(kVK_Control)]];
    }
    if (modifiers & NSAlternateKeyMask) {
        [final appendString:[characterMap objectForKey:@(kVK_Option)]];
    }
    if (modifiers & NSShiftKeyMask) {
        [final appendString:[characterMap objectForKey:@(kVK_Shift)]];
    }
    if (modifiers & NSCommandKeyMask) {
        [final appendString:[characterMap objectForKey:@(kVK_Command)]];
    }
    
    if (keyCode == kVK_Control || keyCode == kVK_Option || keyCode == kVK_Shift || keyCode == kVK_Command) {
        return final;
    }
    
    NSString *mapped = [characterMap objectForKey:@(keyCode)];
    if (mapped != nil) {
        [final appendString:mapped];
    } else {
        
        TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
        CFDataRef uchr = (CFDataRef)TISGetInputSourceProperty(currentKeyboard, kTISPropertyUnicodeKeyLayoutData);
        const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout*)CFDataGetBytePtr(uchr);
        
        if (keyboardLayout) {
            UInt32 deadKeyState = 0;
            UniCharCount maxStringLength = 255;
            UniCharCount actualStringLength = 0;
            UniChar unicodeString[maxStringLength];
            
            UInt32 keyModifiers = DDCarbonModifierFlagsFromCocoaModifiers(modifiers);
            
            OSStatus status = UCKeyTranslate(keyboardLayout,
                                             keyCode, kUCKeyActionDown, keyModifiers,
                                             LMGetKbdType(), 0,
                                             &deadKeyState,
                                             maxStringLength,
                                             &actualStringLength, unicodeString);
            
            if (actualStringLength > 0 && status == noErr) {
                NSString *characterString = [NSString stringWithCharacters:unicodeString length:(NSUInteger)actualStringLength];
                
                [final appendString:characterString];
            }
        }
    }
    
    return final;
}

UInt32 DDCarbonModifierFlagsFromCocoaModifiers(NSUInteger flags) {
    UInt32 newFlags = 0;
    if ((flags & NSControlKeyMask) > 0) { newFlags |= controlKey; }
    if ((flags & NSCommandKeyMask) > 0) { newFlags |= cmdKey; }
    if ((flags & NSShiftKeyMask) > 0) { newFlags |= shiftKey; }
    if ((flags & NSAlternateKeyMask) > 0) { newFlags |= optionKey; }
    if ((flags & NSAlphaShiftKeyMask) > 0) { newFlags |= alphaLock; }
    return newFlags;
}
