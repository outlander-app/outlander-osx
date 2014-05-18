//
//  RountimeNotifier.m
//  Outlander
//
//  Created by Joseph McBride on 5/17/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "RoundtimeNotifier.h"
#import "Roundtime.h"

@interface RoundtimeNotifier () {
    NSInteger _roundtime;
    NSInteger _maxrt;
    NSTimer *_timer;
}
@end

@implementation RoundtimeNotifier

- (instancetype)init {
    self = [super init];
    if(!self)return nil;
    
    _notification = [RACReplaySubject subject];
    _roundtime = 0;
    
    return self;
}

- (void)set:(NSInteger)value {
    
    _roundtime = value;
    _maxrt = value;
    
    [self runTimer];
    
    Roundtime *rt = [[Roundtime alloc] init];
    rt.percent = 1.0;
    rt.value = value;
    [_notification sendNext:rt];
}

- (void)runTimer {
    
    if(_timer) {
        return;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                              target: self
                                            selector: @selector(onTick:)
                                            userInfo: nil
                                             repeats: YES];
}

- (void)onTick:(NSTimer *)t {
    _roundtime -= 1;
    
    double percent = 0;
    
    Roundtime *rt = [[Roundtime alloc] init];
    if(_roundtime <= 0) {
        [_timer invalidate];
        _timer = nil;
    }
    else {
        percent = (double)_roundtime / (double)_maxrt;
    }
    rt.percent = percent;
    rt.value = _roundtime;
    [_notification sendNext:rt];
}

@end
