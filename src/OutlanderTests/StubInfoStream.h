//
//  StubInfoStream.h
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameStream.h"

@interface StubInfoStream : NSObject <InfoStream>

@property (atomic, strong) RACSignal *subject;
@property (atomic, strong) RACMulticastConnection *room;

- (void)publishRoom;
- (void)publishSubject;

@end
