//
//  ScriptRunnerTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/31/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "ScriptRunner.h"
#import "Script.h"
#import "GameContext.h"
#import "StubFileSystem.h"

SPEC_BEGIN(ScriptRunnerTester)

describe(@"Script Runner", ^{
    
    __block ScriptRunner *theRunner = nil;
    __block GameContext *theContext = nil;
    __block StubFileSystem *theFileSystem = nil;
    
    beforeEach(^{
        theContext = [[GameContext alloc] init];
        theFileSystem = [[StubFileSystem alloc] init];
        theRunner = [[ScriptRunner alloc] initWith:theContext and:theFileSystem];
    });
    
    context(@"arguments", ^{
        it(@"sets default arguments", ^{
            
           theFileSystem.fileContents = @"some script info";
            
            NSArray *args = @[@"one", @"two"];
            [theRunner run:@"scriptName" withArgs:args and:@"one two"];
            
            Script *script = [theRunner.scripts cacheObjectForKey:@"scriptName"];
            
            [[[script.localVars cacheObjectForKey:@"0"] should] equal:@"one two"];
            [[[script.localVars cacheObjectForKey:@"1"] should] equal:@"one"];
            [[[script.localVars cacheObjectForKey:@"2"] should] equal:@"two"];
        });
    });
});

SPEC_END