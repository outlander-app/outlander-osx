//
//  GameCommandRelay.h
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "CommandRelay.h"

@class EventAggregator;

@interface GameCommandRelay : NSObject <CommandRelay>

-(instancetype)initWith:(EventAggregator *)aggregator;

@end
