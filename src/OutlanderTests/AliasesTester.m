//
//  HighlightsLoaderTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "AliasLoader.h"
#import "StubFileSystem.h"
#import "Outlander-Swift.h"

QuickSpecBegin(AliasLoaderSpec)

describe(@"Alias Loader", ^{
   
    __block AliasLoader *theLoader = nil;
    __block GameContext *theContext = nil;
    __block StubFileSystem *theFileSystem = nil;
    
    beforeEach(^{
        theContext = [GameContext newInstance];
        theFileSystem = [[StubFileSystem alloc] init];
        theLoader = [[AliasLoader alloc] initWithContext:theContext andFileSystem:theFileSystem];
    });
    
    context(@"load", ^{
        
        it(@"should parse simple alias", ^{
            
            theFileSystem.fileContents = @"#alias {l2} {load arrows}";
            
            [theLoader load];

            expect(@(theContext.aliases.count)).to(equal(@1));

            Alias *alias = [theContext.aliases objectAtIndex:0];
            expect(alias.pattern).to(equal(@"l2"));
            expect(alias.replace).to(equal(@"load arrows blah"));
        });
        
        it(@"should parse multiple aliases", ^{
            
            theFileSystem.fileContents = @"#alias {l2} {load arrows}\n#alias {atk} {.hunt lootcoin lootgem}\n";
            
            [theLoader load];

            expect(@(theContext.aliases.count)).to(equal(@2));

            Alias *alias = [theContext.aliases objectAtIndex:0];
            expect(alias.pattern).to(equal(@"l2"));
            expect(alias.replace).to(equal(@"load arrows"));

            alias = [theContext.aliases objectAtIndex:1];
            expect(alias.pattern).to(equal(@"atk"));
            expect(alias.replace).to(equal(@".hunt lootcoin lootgem"));
        });
    });
    
    context(@"save", ^{
      
        it(@"should save alias", ^{
            
            Alias *hl = [[Alias alloc] init];
            hl.pattern = @"l2";
            hl.replace = @"load arrows";
            [theContext.aliases addObject:hl];
            
            hl = [[Alias alloc] init];
            hl.pattern = @"atk";
            hl.replace = @".hunt lootcoin lootgem";
            [theContext.aliases addObject:hl];
            
            NSString *result = @"#alias {l2} {load arrows}\n#alias {atk} {.hunt lootcoin lootgem}\n";
            
            [theLoader save];
            
            NSString *path = [[theContext.pathProvider profileFolder] stringByAppendingPathComponent:@"aliases.cfg"];

            expect(theFileSystem.givenFileName).to(equal(path));
            expect(theFileSystem.fileContents).to(equal(result));
        });
    });
});

QuickSpecEnd
