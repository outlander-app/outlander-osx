//
//  SpelltimeNotifier.m
//  Outlander
//
//  Created by Joseph McBride on 5/17/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "SpelltimeNotifier.h"
#import "Outlander-Swift.h"

@interface SpelltimeNotifier () {
    NSString *_spell;
    NSInteger _count;
    NSTimer *_timer;
    GameContext *_gameContext;
}
@end

@implementation SpelltimeNotifier

- (instancetype)initWith:(GameContext *)context {
    self = [super init];
    if(!self)return nil;
    
    _gameContext = context;
    _notification = [RACSubject subject];
    [_notification deliverOn:[RACScheduler mainThreadScheduler]];
    _count = 0;
    
    return self;
}

- (void)set:(NSString *)value {
    
    if([_spell isEqualToString:value])
        return;
    
    _spell = value;
    if(!value || value.length == 0 || [value isEqualToString:@"None"])
        _count = 0;
    
    [self sendUpdate];
    [self runTimer];
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
    _count++;
    if(!_spell || _spell.length == 0 || [_spell isEqualToString:@"None"]) {
        _count = 0;
        [_timer invalidate];
        _timer = nil;
    }
    [self sendUpdate];
}

- (void)sendUpdate {
    NSString *sendValue = @"S: None";
    
    if(![_spell isEqualToString:@"None"]) {
        sendValue =[NSString stringWithFormat:@"S: (%ld)%@ ", (long)_count, _spell];
    }
   
    [_notification sendNext:sendValue];
    
    NSString *time = [@(_count) stringValue];
    
    // this is causing issues - is getting a deadlock
    [_gameContext.globalVars setCacheObject:time forKey:@"spelltime"];
}

@end
