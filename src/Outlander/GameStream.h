//
//  GameStream.h
//  Outlander
//
//  Created by Joseph McBride on 1/25/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RACReplaySubject.h"
#import "GameServer.h"
#import "GameParser.h"
#import "GameConnection.h"
#import "TSMutableDictionary.h"

@interface GameStream : NSObject {
    GameServer *_gameServer;
    GameParser *_gameParser;
}
@property (nonatomic, strong) RACReplaySubject *subject;
@property (nonatomic, strong) TSMutableDictionary *globalVars;
-(void) publish:(id)item;
-(void) complete;
-(void) error:(NSError *)error;
-(void) sendCommand:(NSString *)command;
-(RACSignal *) connect:(GameConnection *)connection;
@end
