//
//  SendActor.m
//  Outlander
//
//  Created by Joseph McBride on 6/15/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SendQueueProcessor.h"
#import "CommandRelay.h"
#import "GameCommandRelay.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSString+Categories.h"
#import "Outlander-Swift.h"

@interface SendQueueProcessor () {
    OLPauseCondition *_pauseCondition;
    GameContext *_gameContext;
    doneBlock _doneBlock;
    BOOL _waiting;
}
@end

@implementation SendQueueProcessor

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _pauseCondition = [[OLPauseCondition alloc] init];
    _waiting = NO;
    
    return self;
}

- (void)configure:(GameContext *)context with:(doneBlock)block {
    _gameContext = context;
    _doneBlock = block;
}

- (void)process {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self waitForRoundtime];
    });
}

- (void)waitForRoundtime {
    if(_waiting) return;
    
    _waiting = YES;
    
    NSString *rtString = [_gameContext.globalVars cacheObjectForKey:@"roundtime"];
    
    if([rtString doubleValue] <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _doneBlock();
        });
        return;
    }
    
    __block RACDisposable *signal = nil;
    
    [[[_pauseCondition wait] execute:^(OLPauseCondition *context) {
        signal = [_gameContext.globalVars.changed subscribeNext:^(NSDictionary *changed) {
            
            if([[changed.allKeys firstObject] isEqualToString:@"roundtime"]) {
                
                double roundtime = [changed[@"roundtime"] doubleValue];
                
                if(roundtime <= 0) {
                    [signal dispose];
                    [context signal];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _doneBlock();
                    });
                }
            }
        }];
    } done:^{
    } cancel:^{
        [signal dispose];
    }] run];
}


@end
