//
//  GameEventRelay.h
//  Outlander
//
//  Created by Joseph McBride on 5/31/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "EventRelay.h"
#import "Outlander-Swift.h"

@interface GameEventRelay : NSObject <EventRelay>

- (instancetype)initWith:(EventAggregator *)events;

@end
