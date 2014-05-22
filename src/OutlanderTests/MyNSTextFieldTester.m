//
//  MyNSTextFieldTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "MyNSTextField.h"

SPEC_BEGIN(MyNSTextFieldTester)

describe(@"My TextField", ^{
   
    __block MyNSTextField *_textField = nil;
    
    beforeEach(^{
        _textField = [[MyNSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 24)];
        [_textField configure];
        
        [_textField setStringValue:@"one"];
        [_textField commitHistory];
        [_textField setStringValue:@"two"];
        [_textField commitHistory];
        [_textField setStringValue:@""];
    });
    
    context(@"keeps command history", ^{
        
        it(@"basic behavior", ^{
            
            [[[_textField stringValue] should] equal:@""];
            
            [_textField previousHistory];
            
            [[[_textField stringValue] should] equal:@"two"];
        });
        
        it(@"cycles through previous history", ^{
            [[[_textField stringValue] should] equal:@""];
            
            [_textField previousHistory];
            [[[_textField stringValue] should] equal:@"two"];
            
            [_textField previousHistory];
            [[[_textField stringValue] should] equal:@"one"];
            
            [_textField previousHistory];
            [[[_textField stringValue] should] equal:@""];
            
            [_textField previousHistory];
            [[[_textField stringValue] should] equal:@"two"];
        });
        
        it(@"cycles through next history", ^{
            [[[_textField stringValue] should] equal:@""];
            
            [_textField nextHistory];
            [[[_textField stringValue] should] equal:@"one"];
            
            [_textField nextHistory];
            [[[_textField stringValue] should] equal:@"two"];
            
            [_textField nextHistory];
            [[[_textField stringValue] should] equal:@""];
        });
        
        it(@"does not commit the same value twice", ^{
            [_textField setStringValue:@"two"];
            [_textField commitHistory];
            
            [_textField previousHistory];
            [[[_textField stringValue] should] equal:@"two"];
            
            [_textField previousHistory];
            [[[_textField stringValue] should] equal:@"one"];
        });
    });
});

SPEC_END