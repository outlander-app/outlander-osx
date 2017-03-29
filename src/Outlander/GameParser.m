//
//  GameParser.m
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameParser.h"
#import "NSString+Categories.h"
#import "Outlander-Swift.h"

@implementation GameParser {
    NSArray *_roomTags;
    NSDictionary *_directionNames;
    GameContext *_gameContext;
}

-(id)initWithContext:(GameContext *)context {
    self = [super init];
    if(self == nil) return nil;
    
    _gameContext = context;
    
    _subject = [RACSubject subject];
    _vitals = [RACSubject subject];
    _indicators = [RACSubject subject];
    _room = [RACSubject subject];
    _directions = [RACSubject subject];
    _exp = [RACSubject subject];
    _thoughts = [RACSubject subject];
    _chatter = [RACSubject subject];
    _arrivals = [RACSubject subject];
    _deaths = [RACSubject subject];
    _familiar = [RACSubject subject];
    _log = [RACSubject subject];
    _roundtime = [RACSubject subject];
    _spell = [RACSubject subject];
    
    _currenList = [[NSMutableArray alloc] init];
    _currentResult = [[NSMutableString alloc] init];
    _inStream = NO;
    _publishStream = YES;
    _bold = NO;
    _mono = NO;
    
    _roomTags = @[@"roomdesc", @"roomobjs", @"roomplayers", @"roomexits"];
    _directionNames = @{
                        @"n": @"north",
                        @"s": @"south",
                        @"e": @"east",
                        @"w": @"west",
                        @"ne": @"northeast",
                        @"nw": @"northwest",
                        @"se": @"southeast",
                        @"sw": @"southwest",
                        @"up": @"up",
                        @"down": @"down",
                        @"out": @"out",
                        };
    
    return self;
}

@end
