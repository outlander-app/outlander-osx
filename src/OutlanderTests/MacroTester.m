//
//  MacroTester.m
//  Outlander
//
//  Created by Joseph McBride on 3/28/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "Macro.h"

SPEC_BEGIN(MacroTester)

describe(@"Macro", ^{
   
    context(@"modifiers", ^{
        
        it(@"alt", ^{
            NSUInteger flags = [Macro stringToFlags:@"⌥"];
            [[theValue(flags) should]equal:theValue(NSAlternateKeyMask)];
        });
        
        it(@"control", ^{
            NSUInteger flags = [Macro stringToFlags:@"⌃"];
            [[theValue(flags) should]equal:theValue(NSControlKeyMask)];
        });
        
        it(@"command", ^{
            NSUInteger flags = [Macro stringToFlags:@"⌘"];
            [[theValue(flags) should]equal:theValue(NSCommandKeyMask)];
        });
        
        it(@"shift", ^{
            NSUInteger flags = [Macro stringToFlags:@"⇧"];
            [[theValue(flags) should]equal:theValue(NSShiftKeyMask)];
        });
        
        it(@"control|shift", ^{
            NSUInteger flags = [Macro stringToFlags:@"⌃⇧"];
            [[theValue(flags) should]equal:theValue(NSControlKeyMask|NSShiftKeyMask)];
        });
    });
});

SPEC_END
