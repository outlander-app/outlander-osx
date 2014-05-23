//
//  HighlightsLoaderTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "AliasLoader.h"
#import "GameContext.h"
#import "StubFileSystem.h"

SPEC_BEGIN(AliasesLoaderTester)

describe(@"Alias Loader", ^{
   
    __block AliasLoader *theLoader = nil;
    __block GameContext *theContext = nil;
    __block StubFileSystem *theFileSystem = nil;
    
    beforeEach(^{
        theContext = [[GameContext alloc] init];
        theFileSystem = [[StubFileSystem alloc] init];
        theLoader = [[AliasLoader alloc] initWithContext:theContext andFileSystem:theFileSystem];
    });
    
    context(@"load", ^{
        
        it(@"should parse simple alias", ^{
            
            theFileSystem.fileContents = @"#alias {l2} {load arrows}";
            
            [theLoader load];
            [[theContext.aliases should] haveCountOf:1];
            
            Alias *alias = theContext.aliases[0];
            [[alias.pattern should] equal:@"l2"];
            [[alias.replace should] equal:@"load arrows"];
        });
        
        it(@"should parse multiple aliases", ^{
            
            theFileSystem.fileContents = @"#alias {l2} {load arrows}\n#alias {atk} {.hunt lootcoin lootgem}";
            
            [theLoader load];
            [[theContext.aliases should] haveCountOf:2];
            
            Alias *alias = theContext.aliases[0];
            [[alias.pattern should] equal:@"l2"];
            [[alias.replace should] equal:@"load arrows"];
            
            alias = theContext.aliases[1];
            [[alias.pattern should] equal:@"atk"];
            [[alias.replace should] equal:@".hunt lootcoin lootgem"];
        });
    });
});

SPEC_END
