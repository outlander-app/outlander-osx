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

#import "VarCommandHandler.h"
#import "Outlander-Swift.h"

QuickSpecBegin(VarCommandHandlerSpec)

describe(@"var command handler", ^{
   
    __block VarCommandHandler *theHandler = nil;
    __block GameContext *theContext = nil;
    __block NSInteger originalCount;
    
    beforeEach(^{
        theHandler = [[VarCommandHandler alloc] init];
        theContext = [GameContext newInstance];
        
        originalCount = theContext.globalVars.count;
    });
    
    context(@"can handle", ^{
        it(@"success", ^{
            BOOL result = [theHandler canHandle:@"#var one two"];
            expect(@(result)).to(equal(@YES));
        });
        
        it(@"failure", ^{
            BOOL result = [theHandler canHandle:@"var one two"];
            expect(@(result)).to(equal(@NO));
        });
    });
    
    context(@"handle", ^{
        it(@"sets global var", ^{
            [theHandler handle:@"#var one two" withContext:theContext];
            
            NSString *value = [theContext.globalVars get:@"one"];
            expect(value).to(equal(@"two"));
            expect(@(theContext.globalVars.count)).to(equal(@(originalCount + 1)));
        });
        
        it(@"sets global var", ^{
            [theHandler handle:@"#var one two three four" withContext:theContext];
            
            NSString *value = [theContext.globalVars get:@"one"];
            expect(value).to(equal(@"two three four"));
            expect(@(theContext.globalVars.count)).to(equal(@(originalCount + 1)));
        });
        
        it(@"updates existing global var", ^{
            [theHandler handle:@"#var one two" withContext:theContext];
            
            NSString *value = [theContext.globalVars get:@"one"];
            expect(value).to(equal(@"two"));
            expect(@(theContext.globalVars.count)).to(equal(@(originalCount + 1)));

            [theHandler handle:@"#var one three" withContext:theContext];
            
            value = [theContext.globalVars get:@"one"];
            expect(value).to(equal(@"three"));

            expect(@(theContext.globalVars.count)).to(equal(@(originalCount + 1)));
        });
    });
});

QuickSpecEnd
