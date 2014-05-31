//
//  StubInfoStream.h
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameStream.h"

@interface StubInfoStream : NSObject <InfoStream>

@property (atomic, strong) RACMulticastConnection *subject;
@property (atomic, strong) RACMulticastConnection *room;
@property (nonatomic, copy) NSString *lastSubject;

- (void)publishRoom;
- (void)publishSubject:(NSString *)data;

@end
