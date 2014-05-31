//
//  StubInfoStream.m
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "StubInfoStream.h"

@interface StubInfoStream () {
    RACSubject *_roomSub;
    RACSubject *_mainSub;
}
@end

@implementation StubInfoStream

-(instancetype)init {
    self = [super init];
    if(!self) return nil;
  
    _mainSub = [RACSubject subject];
    _subject = [_mainSub multicast:[RACSubject subject]];
    [_subject connect];
    
    _roomSub = [RACSubject subject];
    _room = [_roomSub multicast:[RACSubject subject]];
    [_room connect];
    
    return self;
}

- (void)publishRoom {
    [_roomSub sendNext:nil];
}

- (void)publishSubject:(NSString *)data {
    _lastSubject = data;
    [_mainSub sendNext:data];
}

@end
