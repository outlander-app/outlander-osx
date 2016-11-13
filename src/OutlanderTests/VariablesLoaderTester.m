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

#import "VariablesLoader.h"
#import "StubFileSystem.h"
#import "Outlander-Swift.h"

QuickSpecBegin(VariablesLoaderSpec)

describe(@"Variables Loader", ^{
   
    __block VariablesLoader *theLoader = nil;
    __block GameContext *theContext = nil;
    __block StubFileSystem *theFileSystem = nil;
    __block NSUInteger originalCount;
    
    beforeEach(^{
        theContext = [GameContext newInstance];
        theFileSystem = [[StubFileSystem alloc] init];
        theLoader = [[VariablesLoader alloc] initWithContext:theContext andFileSystem:theFileSystem];
       
        // default vars
        originalCount = 6;
    });
    
    context(@"load", ^{
        
        it(@"should parse simple variable", ^{
            
            theFileSystem.fileContents = @"#var {key} {some value}";
            
            [theLoader load];
            expect(@(theContext.globalVars.count)).to(equal(@(originalCount + 1)));

            expect([theContext.globalVars cacheObjectForKey:@"key"]).to(equal(@"some value"));
        });
        
        it(@"should parse multiple vars", ^{
            
            theFileSystem.fileContents = @"#var {key1} {some value}\n#var {key2} {some other value}";
            
            [theLoader load];
            expect(@(theContext.globalVars.count)).to(equal(@(originalCount + 2)));

            expect([theContext.globalVars cacheObjectForKey:@"key1"]).to(equal(@"some value"));
            expect([theContext.globalVars cacheObjectForKey:@"key2"]).to(equal(@"some other value"));
        });
    });
    
    context(@"save", ^{
      
        it(@"should save variables", ^{
            
            NSString *result = @"#var {lefthand} {Empty}\n#var {preparedspell} {None}\n#var {prompt} {>}\n#var {righthand} {Empty}\n#var {tdp} {0}\n";
           
            [theLoader load];
            [theLoader save];
            
            NSString *path = [[theContext.pathProvider profileFolder] stringByAppendingPathComponent:@"variables.cfg"];

            expect(theFileSystem.givenFileName).to(equal(path));
            expect(theFileSystem.fileContents).to(equal(result));
        });
    });
});

QuickSpecEnd
