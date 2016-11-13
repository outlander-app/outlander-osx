//
//  MacroTester.m
//  Outlander
//
//  Created by Joseph McBride on 3/28/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "Macro.h"

QuickSpecBegin(MacroSpec)

describe(@"Macro", ^{
   
    context(@"modifiers", ^{
        
        it(@"alt", ^{
            NSUInteger flags = [Macro stringToFlags:@"⌥"];
            expect(@(flags)).to(equal(@(NSAlternateKeyMask)));
        });
        
        it(@"control", ^{
            NSUInteger flags = [Macro stringToFlags:@"⌃"];
            expect(@(flags)).to(equal(@(NSControlKeyMask)));
        });
        
        it(@"command", ^{
            NSUInteger flags = [Macro stringToFlags:@"⌘"];
            expect(@(flags)).to(equal(@(NSCommandKeyMask)));
        });
        
        it(@"shift", ^{
            NSUInteger flags = [Macro stringToFlags:@"⇧"];
            expect(@(flags)).to(equal(@(NSShiftKeyMask)));
        });
        
        it(@"control|shift", ^{
            NSUInteger flags = [Macro stringToFlags:@"⌃⇧"];
            expect(@(flags)).to(equal(@(NSControlKeyMask|NSShiftKeyMask)));
        });
    });
});

QuickSpecEnd
