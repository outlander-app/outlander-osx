//
//  ScriptTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/28/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "Script.h"
#import "GameContext.h"

SPEC_BEGIN(ScriptTester)

describe(@"Script", ^{
    
    __block Script *theScript = nil;
    __block GameContext *theContext = nil;
    
    beforeEach(^{
        theContext = [[GameContext alloc] init];
    });
    
    context(@"vars", ^{
       
        beforeEach(^{
            
            NSString *sample = @"var one two";
            
            theScript = [[Script alloc] initWith:theContext and:sample];
        });
        
        it(@"set local var", ^{
            
            [theScript process];
            
            NSString *one = [theScript.localVars cacheObjectForKey:@"one"];
            
            [[one should] equal:@"two"];
        });
    });
    
    context(@"commands", ^{
       
        beforeEach(^{
            
            NSString *sample = @"#script one two";
            
            theScript = [[Script alloc] initWith:theContext and:sample];
        });
        
        it(@"send script command", ^{
            
            [theScript process];
        });
    });
});

SPEC_END
