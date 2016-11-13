//
//  VarCommandHandlerTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "HighlightCommandHandler.h"
#import "Highlight.h"
#import "Outlander-Swift.h"

QuickSpecBegin(HighlightCommandHandlerSpec)

describe(@"highlight command handler", ^{
   
    __block HighlightCommandHandler *theHandler = nil;
    __block GameContext *theContext = nil;
    
    beforeEach(^{
        theHandler = [[HighlightCommandHandler alloc] init];
        theContext = [GameContext newInstance];
    });
    
    context(@"can handle", ^{
        it(@"success", ^{
            BOOL result = [theHandler canHandle:@"#highlight #000fff something"];
            expect(@(result)).to(equal(@YES));
        });
        
        it(@"failure", ^{
            BOOL result = [theHandler canHandle:@"highlight one two"];
            expect(@(result)).to(equal(@NO));
        });
    });
    
    context(@"handle", ^{
        it(@"adds highlight to collection", ^{
            [theHandler handle:@"#highlght #000fff something" withContext:theContext];
            
            Highlight *hl = [theContext.highlights objectAtIndex:0];
            expect(hl.color).to(equal(@"#000fff"));
            expect(hl.pattern).to(equal(@"something"));
        });
        
        it(@"adds highlight to collection", ^{
            [theHandler handle:@"#highlght #000fff something with more text" withContext:theContext];
            
            Highlight *hl = [theContext.highlights objectAtIndex:0];
            expect(hl.color).to(equal(@"#000fff"));
            expect(hl.pattern).to(equal(@"something with more text"));
        });
        
        it(@"updates an existing highlight", ^{
            [theHandler handle:@"#highlght #000fff something" withContext:theContext];
            
            Highlight *hl = [theContext.highlights objectAtIndex:0];
            expect(hl.color).to(equal(@"#000fff"));
            expect(hl.pattern).to(equal(@"something"));

            [theHandler handle:@"#highlght #fcfcfc something" withContext:theContext];

            expect(@(theContext.highlights.count)).to(equal(@1));
        });
    });
});

QuickSpecEnd