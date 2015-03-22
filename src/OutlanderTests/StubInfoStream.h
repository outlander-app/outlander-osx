//
//  StubInfoStream.h
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Shared.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface StubInfoStream : NSObject <InfoStream>

@property (atomic, strong) RACMulticastConnection *subject;
@property (atomic, strong) RACMulticastConnection *room;
@property (atomic, strong) RACMulticastConnection *spell;
@property (nonatomic, strong) id lastSubject;

- (void)publishRoom;
- (void)publishSubject:(id)data;

@end
