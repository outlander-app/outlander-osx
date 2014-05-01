//
//  TextViewControllerTester.m
//  Outlander
//
//  Created by Joseph McBride on 4/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "TestViewController.h"
#import "TextTag.h"

SPEC_BEGIN(TestViewControllerTester)

describe(@"TestViewControllerTester", ^{
    
    __block TestViewController *controller;
    
    beforeEach(^{
        controller = [[TestViewController alloc] init];
    });
    
    it(@"should not append prompt multiple times", ^{
        
//        [controller addWindow:@"main" withRect:NSMakeRect(0, 0, 100, 100)];
//        
//        [controller append:[TextTag tagFor:@">\r\n" mono:false] to:@"main"];
//        [controller append:[TextTag tagFor:@">\r\n" mono:false] to:@"main"];
//        
//        NSString *text = [controller textForWindow:@"main"];
//        [[text should] equal:@">\r\n"];
    });
});

SPEC_END