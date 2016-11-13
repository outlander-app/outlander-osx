//
//  HighlightsLoaderTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "HighlightsLoader.h"
#import "StubFileSystem.h"
#import "Outlander-Swift.h"

QuickSpecBegin(HighlightsLoaderSpec)

describe(@"Highlights Loader", ^{
   
    __block HighlightsLoader *theLoader = nil;
    __block GameContext *theContext = nil;
    __block StubFileSystem *theFileSystem = nil;
    
    beforeEach(^{
        theContext = [GameContext newInstance];
        theFileSystem = [[StubFileSystem alloc] init];
        theLoader = [[HighlightsLoader alloc] initWithContext:theContext andFileSystem:theFileSystem];
    });
    
    context(@"load", ^{
        
        it(@"should parse simple highlight", ^{
            
            theFileSystem.fileContents = @"#highlight {#AD0000} {a silver clenched fist}";
            
            [theLoader load];
            expect(@(theContext.highlights.count)).to(equal(@1));

            Highlight *highlight = [theContext.highlights objectAtIndex:0];
            expect(highlight.pattern).to(equal(@"a silver clenched fist"));
            expect(highlight.color).to(equal(@"#AD0000"));
            expect(highlight.backgroundColor).to(equal(@""));
        });

        it(@"should parse simple highlight with background color", ^{
            
            theFileSystem.fileContents = @"#highlight {#AD0000, #efefef} {a silver clenched fist}";
            
            [theLoader load];
            expect(@(theContext.highlights.count)).to(equal(@1));
            
            Highlight *highlight = [theContext.highlights objectAtIndex:0];
            expect(highlight.pattern).to(equal(@"a silver clenched fist"));
            expect(highlight.color).to(equal(@"#AD0000"));
            expect(highlight.backgroundColor).to(equal(@"#efefef"));
        });
        
        it(@"should parse multiple highlights", ^{
            
            theFileSystem.fileContents = @"#highlight {#AD0000} {a silver clenched fist}\n#highlight {#0000FF, #efefef} {^You've gained a new rank.*$}";
            
            [theLoader load];
            expect(@(theContext.highlights.count)).to(equal(@2));

            Highlight *highlight = [theContext.highlights objectAtIndex:0];
            expect(highlight.pattern).to(equal(@"a silver clenched fist"));
            expect(highlight.color).to(equal(@"#AD0000"));
            expect(highlight.backgroundColor).to(equal(@""));
            
            highlight = [theContext.highlights objectAtIndex:1];
            expect(highlight.pattern).to(equal(@"^You've gained a new rank.*$"));
            expect(highlight.color).to(equal(@"#0000FF"));
            expect(highlight.backgroundColor).to(equal(@"#efefef"));
        });
    });
    
    context(@"save", ^{
      
        it(@"should save highlights", ^{
            
            Highlight *hl = [[Highlight alloc] init];
            hl.color = @"#AD0000";
            hl.pattern = @"a silver clenched fist";
            [theContext.highlights addObject:hl];
            
            hl = [[Highlight alloc] init];
            hl.color = @"#0000FF";
            hl.backgroundColor = @"#efefef";
            hl.pattern = @"^You've gained a new rank.*$";
            [theContext.highlights addObject:hl];
            
            NSString *result = @"#highlight {#AD0000} {a silver clenched fist}\n#highlight {#0000FF,#efefef} {^You've gained a new rank.*$}\n";
            
            [theLoader save];
            
            NSString *path = [[theContext.pathProvider profileFolder] stringByAppendingPathComponent:@"highlights.cfg"];

            expect(theFileSystem.givenFileName).to(equal(path));
            expect(theFileSystem.fileContents).to(equal(result));
        });
    });
});

QuickSpecEnd
