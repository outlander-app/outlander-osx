//
//  HighlightsLoaderTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "HighlightsLoader.h"
#import "GameContext.h"
#import "StubFileSystem.h"

SPEC_BEGIN(HighlightsLoaderTester)

describe(@"Highlights Loader", ^{
   
    __block HighlightsLoader *theLoader = nil;
    __block GameContext *theContext = nil;
    __block StubFileSystem *theFileSystem = nil;
    
    beforeEach(^{
        theContext = [[GameContext alloc] init];
        theFileSystem = [[StubFileSystem alloc] init];
        theLoader = [[HighlightsLoader alloc] initWithContext:theContext andFileSystem:theFileSystem];
    });
    
    context(@"load", ^{
        
        it(@"should parse simple highlight", ^{
            
            theFileSystem.fileContents = @"#highlight {#AD0000} {a silver clenched fist}";
            
            [theLoader load];
            [[theContext.highlights should] haveCountOf:1];
            
            Highlight *highlight = [theContext.highlights objectAtIndex:0];
            [[highlight.pattern should] equal:@"a silver clenched fist"];
            [[highlight.color should] equal:@"#AD0000"];
        });
        
        it(@"should parse multiple highlights", ^{
            
            theFileSystem.fileContents = @"#highlight {#AD0000} {a silver clenched fist}\n#highlight {#0000FF} {^You've gained a new rank.*$}";
            
            [theLoader load];
            [[theContext.highlights should] haveCountOf:2];
            
            Highlight *highlight = [theContext.highlights objectAtIndex:0];
            [[highlight.pattern should] equal:@"a silver clenched fist"];
            [[highlight.color should] equal:@"#AD0000"];
            
            highlight = [theContext.highlights objectAtIndex:1];
            [[highlight.pattern should] equal:@"^You've gained a new rank.*$"];
            [[highlight.color should] equal:@"#0000FF"];
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
            hl.pattern = @"^You've gained a new rank.*$";
            [theContext.highlights addObject:hl];
            
            NSString *result = @"#highlight {#AD0000} {a silver clenched fist}\n#highlight {#0000FF} {^You've gained a new rank.*$}\n";
            
            [theLoader save];
            
            NSString *path = [[theContext.pathProvider profileFolder] stringByAppendingPathComponent:@"highlights.cfg"];
            
            [[theFileSystem.givenFileName should] equal:path];
            [[theFileSystem.fileContents should] equal:result];
        });
    });
});

SPEC_END
