//
//  DDKeyCodesFromStringTester.m
//  Outlander
//
//  Created by Joseph McBride on 6/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "DDHotKeyUtilities.h"
#import <Carbon/Carbon.h>

SPEC_BEGIN(DDKeyCodesFromStringTester)

describe(@"Key Codes", ^{
    
    it(@"converts known string to keycode", ^{
        DDKeyCodes result = DDKeyCodesFromString(@"F1");
        [[theValue(result.keyCode) should] equal:theValue(kVK_F1)];
    });
    
    it(@"converts known string 'A' to keycode", ^{
        DDKeyCodes result = DDKeyCodesFromString(@"A");
        [[theValue(result.keyCode) should] equal:theValue(kVK_ANSI_A)];
    });
    
    it(@"converts known string with modifier to keycode", ^{
        DDKeyCodes result = DDKeyCodesFromString(@"⌘F1");
        [[theValue(result.keyCode) should] equal:theValue(kVK_F1)];
        [[theValue(result.modifiers) should] equal:theValue(NSCommandKeyMask)];
    });
});

SPEC_END