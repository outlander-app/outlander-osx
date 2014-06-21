//
//  TestViewControllerTests.m
//  Outlander
//
//  Created by Joseph McBride on 6/18/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "TestViewController.h"

SPEC_BEGIN(TestViewControllerTests)

describe(@"TestViewController", ^{
   
    context(@"room objs tags builder", ^{
       
        __block TestViewController *theController;
        
        beforeEach(^{
            theController = [[TestViewController alloc] init];
        });
        
        it(@"should create monster bold tags", ^{
            NSString *data = @"You also see <pushbold></pushbold>a musk hog<popbold></popbold> and <pushbold></pushbold>a musk hog<popbold></popbold>.";
            NSArray *tags = [theController tagsForRoomObjs:data];
            
            [[tags should] haveCountOf:5];
            
            TextTag *tag = tags[0];
            [[tag.text should] equal:@"You also see "];
            
            tag = tags[1];
            [[tag.text should] equal:@"a musk hog"];
            [[theValue(tag.bold) should] equal:theValue(YES)];
            
            tag = tags[2];
            [[tag.text should] equal:@" and "];
            
            tag = tags[3];
            [[tag.text should] equal:@"a musk hog"];
            [[theValue(tag.bold) should] equal:theValue(YES)];
            
            tag = tags[4];
            [[tag.text should] equal:@"."];
        });
    });
});

SPEC_END