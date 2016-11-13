//
//  TestViewControllerTests.m
//  Outlander
//
//  Created by Joseph McBride on 6/18/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//
#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "RoomObjsTags.h"

QuickSpecBegin(RoomObjsTagsSpec)

describe(@"RoomObjcsTags", ^{
   
    context(@"room objs tags builder", ^{
       
        __block RoomObjsTags *theController;
        
        beforeEach(^{
            theController = [[RoomObjsTags alloc] init];
        });
        
        it(@"should create monster bold tags", ^{
            NSString *data = @"You also see <pushbold/>a musk hog<popbold/> and <pushbold/>a musk hog<popbold/>.";
            NSArray *tags = [theController tagsForRoomObjs:data];

            expect(@(tags.count)).to(equal(@5));
            
            TextTag *tag = tags[0];
            expect(tag.text).to(equal(@"You also see "));

            tag = tags[1];
            expect(tag.text).to(equal(@"a musk hog"));
            expect(@(tag.bold)).to(equal(@YES));
            
            tag = tags[2];
            expect(tag.text).to(equal(@" and "));

            tag = tags[3];
            expect(tag.text).to(equal(@"a musk hog"));
            expect(@(tag.bold)).to(equal(@YES));

            tag = tags[4];
            expect(tag.text).to(equal(@"."));
        });
    });
});

QuickSpecEnd
