//
//  GameConnection.h
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameConnection : NSObject

@property (nonatomic, copy) NSString *game;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) UInt16 port;
@property (nonatomic, copy) NSString *key;

- (id)initForGame:(NSString *)game host:(NSString *)host port:(UInt16)port key:(NSString *)key;
+ (id)connectionForGame:(NSString *)game host:(NSString *)host port:(UInt16) port key:(NSString *)key;

@end
