//
//  GameEventRelay.m
//  Outlander
//
//  Created by Joseph McBride on 5/31/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameEventRelay.h"

@interface GameEventRelay() {
    EventAggregator *_events;
}
@end

@implementation GameEventRelay

- (instancetype)initWith:(EventAggregator *)events {
    self = [super init];
    if (self) {
        _events = events;
    }
    return self;
}

- (void)send:(NSString *)event with:(NSDictionary *)data {
    
    [_events publish:event data:data];
    
//    [[NSNotificationCenter defaultCenter]
//        postNotificationName:event
//                      object:self
//                    userInfo:data];
}

@end
