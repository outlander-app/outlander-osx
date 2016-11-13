//
//  AppSettingsTester.m
//  Outlander
//
//  Created by Joseph McBride on 5/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "AppSettings.h"

QuickSpecBegin(AppSettingsSpec)

describe(@"AppSettings", ^{
    
    __block AppSettings *theSettings;
   
    beforeEach(^{
        theSettings = [[AppSettings alloc] init];
    });
    
    context(@"init", ^{
        
        it(@"should default login information", ^{

            expect(theSettings.account).to(equal(@""));
            expect(theSettings.password).to(equal(@""));
            expect(theSettings.character).to(equal(@""));
            expect(theSettings.game).to(equal(@"DR"));
            expect(theSettings.profile).to(equal(@"Default"));
        });
    });
    
});

QuickSpecEnd
