//
//  StubEventRelay.h
//  Outlander
//
//  Created by Joseph McBride on 5/31/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "EventRelay.h"

@interface StubEventRelay : NSObject <EventRelay>

@property (nonatomic, strong) NSString *lastEvent;
@property (nonatomic, strong) NSDictionary *lastEventData;

@end
