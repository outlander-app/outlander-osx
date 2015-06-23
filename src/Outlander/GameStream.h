//
//  GameStream.h
//  Outlander
//
//  Created by Joseph McBride on 1/25/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//
#import "GameServer.h"
#import "GameParser.h"
#import "GameConnection.h"
#import "Shared.h"
#import "Outlander-Swift.h"

@interface GameStream : NSObject <InfoStream> {
    GameServer *_gameServer;
    GameParser *_gameParser;
}
@property (atomic, strong) RACMulticastConnection *subject;
@property (atomic, strong) RACSignal *connected;
@property (atomic, strong) RACSubject *vitals;
@property (atomic, strong) RACSignal *indicators;
@property (atomic, strong) RACSignal *directions;
@property (atomic, strong) RACMulticastConnection *room;
@property (atomic, strong) RACSubject *exp;
@property (atomic, strong) RACSignal *thoughts;
@property (atomic, strong) RACSignal *chatter;
@property (atomic, strong) RACSignal *arrivals;
@property (atomic, strong) RACSignal *deaths;
@property (atomic, strong) RACSignal *familiar;
@property (atomic, strong) RACSignal *log;
@property (atomic, strong) RACSubject *roundtime;
@property (atomic, strong) RACMulticastConnection *spell;

-(id) initWithContext:(GameContext *)context;
-(void) publish:(id)item;
-(void) complete;
-(void) unsubscribe;
-(void) error:(NSError *)error;
-(void) sendCommand:(NSString *)command;
-(RACMulticastConnection *) connect:(GameConnection *)connection;
@end
