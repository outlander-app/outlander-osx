//
//  SubstituteTester.m
//  Outlander
//
//  Created by Joseph McBride on 12/24/16.
//  Copyright © 2016 Joe McBride. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "TextViewController.h"
#import "Alias.h"
#import "Outlander-Swift.h"

QuickSpecBegin(SubstituteSpec)

describe(@"Substitute Specs", ^{

    __block TextViewController *_replacer;
    __block GameContext *_context;

    beforeEach(^{
        _replacer = [[TextViewController alloc] initWithKey:@"subtest"];
        _context = [GameContext newInstance];
        [_replacer setGameContext: _context];
    });

    context(@"substitutes", ^{

        it(@"sub thoughts", ^{
            Substitute *sub = [[Substitute alloc] init:@"You hear your mental voice echo to (\\w+), " :@"<to $1:>" :@""];
            [_context.substitutes addObject:sub];

            NSString *result = [_replacer processSubs:@"You hear your mental voice echo to somebody, "];

            expect(result).to(equal(@"<to somebody:>"));
        });
    });
});

QuickSpecEnd
