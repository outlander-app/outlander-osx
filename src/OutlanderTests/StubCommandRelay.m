//
//  StubCommandRelay.m
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "StubCommandRelay.h"

@implementation StubCommandRelay

- (void)sendCommand:(CommandContext *)ctx {
    _lastCommand = ctx;
}

- (void)sendEcho:(TextTag *)tag {
    _lastEcho = tag;
}

@end
