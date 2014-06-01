//
//  StubEventRelay.m
//  Outlander
//
//  Created by Joseph McBride on 5/31/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "StubEventRelay.h"

@implementation StubEventRelay

- (void)send:(NSString *)event with:(NSDictionary *)data {
    _lastEvent = event;
    _lastEventData = data;
}

@end
