//
//  AppSettingsTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Kiwi.h"
#import "AppSettings.h"

SPEC_BEGIN(AppSettingsTester)

describe(@"AppSettings", ^{
    
    __block AppSettings *theSettings;
   
    beforeEach(^{
        theSettings = [[AppSettings alloc] init];
    });
    
    context(@"init", ^{
        
        it(@"should default login information", ^{
            [[theSettings.account should] equal:@""];
            [[theSettings.password should] equal:@""];
            [[theSettings.character should] equal:@""];
            [[theSettings.game should] equal:@"DR"];
            [[theSettings.profile should] equal:@"Default"];
        });
    });
    
});

SPEC_END
