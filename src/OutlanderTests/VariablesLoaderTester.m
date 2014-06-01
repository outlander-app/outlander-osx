//
//  HighlightsLoaderTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "VariablesLoader.h"
#import "GameContext.h"
#import "StubFileSystem.h"

SPEC_BEGIN(VariblesLoaderTester)

describe(@"Variables Loader", ^{
   
    __block VariablesLoader *theLoader = nil;
    __block GameContext *theContext = nil;
    __block StubFileSystem *theFileSystem = nil;
    __block NSUInteger originalCount;
    
    beforeEach(^{
        theContext = [[GameContext alloc] init];
        theFileSystem = [[StubFileSystem alloc] init];
        theLoader = [[VariablesLoader alloc] initWithContext:theContext andFileSystem:theFileSystem];
        
        originalCount = [theContext.globalVars count];
    });
    
    context(@"load", ^{
        
        it(@"should parse simple variable", ^{
            
            theFileSystem.fileContents = @"#var {key} {some value}";
            
            [theLoader load];
            [[theContext.globalVars should] haveCountOf:originalCount + 1];
            
            [[[theContext.globalVars cacheObjectForKey:@"key"] should] equal:@"some value"];
        });
        
        it(@"should parse multiple vars", ^{
            
            theFileSystem.fileContents = @"#var {key1} {some value}\n#var {key2} {some other value}";
            
            [theLoader load];
            [[theContext.globalVars should] haveCountOf:originalCount + 2];
            
            [[[theContext.globalVars cacheObjectForKey:@"key1"] should] equal:@"some value"];
            [[[theContext.globalVars cacheObjectForKey:@"key2"] should] equal:@"some other value"];
        });
    });
    
    context(@"save", ^{
      
        it(@"should save variables", ^{
            
            NSString *result = @"#var {lefthand} {Empty}\n#var {preparedspell} {None}\n#var {prompt} {>}\n#var {righthand} {Empty}\n#var {tdp} {0}\n";
           
            [theLoader save];
            
            NSString *path = [[theContext.pathProvider profileFolder] stringByAppendingPathComponent:@"variables.cfg"];
            
            [[theFileSystem.givenFileName should] equal:path];
            [[theFileSystem.fileContents should] equal:result];
        });
    });
});

SPEC_END
