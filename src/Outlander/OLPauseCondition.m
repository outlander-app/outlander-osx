//
//  OEPauseCondition.m
//  Outlander
//
//  Created by Joseph McBride on 6/13/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "OLPauseCondition.h"

@interface OLPauseCondition () {
    BOOL _paused;
    BOOL _signaled;
    BOOL _canceled;
    BOOL _timedOut;
    NSCondition *_condition;
}
@end

@implementation OLPauseCondition

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _condition = [[NSCondition alloc] init];
    _paused = NO;
    _canceled = NO;
    _signaled = NO;
    _timedOut = NO;

    return self;
}

- (BOOL)isPaused {
    return _paused;
}

- (BOOL)isTimedOut {
    return _timedOut;
}

- (void)cancel {
    _canceled = YES;
    if(_paused) {
        _signaled = YES;
        [_condition signal];
    }
    _paused = NO;
}

- (void)signal {
    if(_paused) {
        _signaled = YES;
        _timedOut = NO;
        [_condition signal];
    }
}

- (ExecuteBlock *)wait {
    return [self execute:^{
        [_condition wait];
    }];
}

- (ExecuteBlock *)waitUntilTimeInterval:(NSTimeInterval)interval {
    return [self execute:^{
        _timedOut = YES;
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:interval];
        [_condition waitUntilDate:date];
        if(_timedOut) {
            _signaled = YES;
        }
    }];
}

- (ExecuteBlock *)execute:(void(^)())block {
    return [[ExecuteBlock alloc] initWith:^(ExecuteBlock *eblock) {
        _paused = YES;
        _signaled = NO;
        [_condition lock];
        
        eblock.doExecute(self);
        
        while(!_signaled){
            block();
        }
        
        [_condition unlock];
        
        if(!_canceled) {
            _paused = NO;
           
            if(eblock.doDone) {
                eblock.doDone();
            }
        }
    }];
}

@end
