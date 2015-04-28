//
//  GameCommandRelay.m
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameCommandRelay.h"
#import "Outlander-Swift.h"

@interface GameCommandRelay() {
    EventAggregator *_aggregator;
}
@end

@implementation GameCommandRelay

- (instancetype)initWith:(EventAggregator *)aggregator {
    self = [super init];
    if (self) {
        _aggregator = aggregator;
    }
    return self;
}

- (void)sendCommand:(CommandContext *)ctx {
    
    NSDictionary *userInfo = @{@"command": ctx};
    
    [_aggregator publish:@"OL:command" data:userInfo];
}

- (void)sendEcho:(TextTag *)tag {
    
    NSDictionary *userInfo = @{@"tag": tag};
    
    [_aggregator publish:@"OL:echo" data:userInfo];
}

@end
