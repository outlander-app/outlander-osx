//
//  VarCommandHandlerTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "HighlightCommandHandler.h"
#import "Highlight.h"
#import "Outlander-Swift.h"

SPEC_BEGIN(HighlightCommandHandlerTester)

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
            [[theValue(result) should] equal:theValue(YES)];
        });
        
        it(@"failure", ^{
            BOOL result = [theHandler canHandle:@"highlight one two"];
            [[theValue(result) should] equal:theValue(NO)];
        });
    });
    
    context(@"handle", ^{
        it(@"adds highlight to collection", ^{
            [theHandler handle:@"#highlght #000fff something" withContext:theContext];
            
            Highlight *hl = [theContext.highlights objectAtIndex:0];
            [[hl.color should] equal:@"#000fff"];
            [[hl.pattern should] equal:@"something"];
        });
        
        it(@"adds highlight to collection", ^{
            [theHandler handle:@"#highlght #000fff something with more text" withContext:theContext];
            
            Highlight *hl = [theContext.highlights objectAtIndex:0];
            [[hl.color should] equal:@"#000fff"];
            [[hl.pattern should] equal:@"something with more text"];
        });
        
        it(@"updates an existing highlight", ^{
            [theHandler handle:@"#highlght #000fff something" withContext:theContext];
            
            Highlight *hl = [theContext.highlights objectAtIndex:0];
            [[hl.color should] equal:@"#000fff"];
            [[hl.pattern should] equal:@"something"];
            
            [theHandler handle:@"#highlght #fcfcfc something" withContext:theContext];
            
            [[theValue(theContext.highlights.count) should] equal:theValue(1)];
        });
    });
});

SPEC_END