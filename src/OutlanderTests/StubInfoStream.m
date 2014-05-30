//
//  StubInfoStream.m
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "StubInfoStream.h"

@interface StubInfoStream () {
    RACSubject *_sub;
}
@end

@implementation StubInfoStream

-(instancetype)init {
    self = [super init];
    if(!self) return nil;
  
    _subject = [RACSubject subject];
    _sub = [RACSubject subject];
    _room = [_sub multicast:[RACSubject subject]];
    
    return self;
}

- (void)publishRoom {
    [_sub sendNext:nil];
}

- (void)publishSubject {
    id<RACSubscriber> sub = (id<RACSubscriber>)_subject;
    [sub sendNext:nil];
}

@end
