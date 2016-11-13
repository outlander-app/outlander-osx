//
//  MyNSTextFieldTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "MyNSTextField.h"

QuickSpecBegin(MyNSTextFieldSpec)

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

            expect(_textField.stringValue).to(equal(@""));
            
            [_textField previousHistory];

            expect(_textField.stringValue).to(equal(@"two"));
        });
        
        it(@"cycles through previous history", ^{
            expect(_textField.stringValue).to(equal(@""));

            [_textField previousHistory];
            expect(_textField.stringValue).to(equal(@"two"));

            [_textField previousHistory];
            expect(_textField.stringValue).to(equal(@"one"));

            [_textField previousHistory];
            expect(_textField.stringValue).to(equal(@""));

            [_textField previousHistory];
            expect(_textField.stringValue).to(equal(@"two"));
        });
        
        it(@"cycles through next history", ^{
            expect(_textField.stringValue).to(equal(@""));

            [_textField nextHistory];
            expect(_textField.stringValue).to(equal(@"one"));

            [_textField nextHistory];
            expect(_textField.stringValue).to(equal(@"two"));

            [_textField nextHistory];
            expect(_textField.stringValue).to(equal(@""));
        });
        
        it(@"does not commit the same value twice", ^{
            [_textField setStringValue:@"two"];
            [_textField commitHistory];
            
            [_textField previousHistory];
            expect(_textField.stringValue).to(equal(@"two"));

            [_textField previousHistory];
            expect(_textField.stringValue).to(equal(@"one"));
        });
    });
});

QuickSpecEnd
