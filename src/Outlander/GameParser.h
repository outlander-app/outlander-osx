//
//  GameParser.h
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ReactiveCocoa.h"
#import "TSMutableDictionary.h"
#import "Shared.h"
#import "GameContext.h"

@interface GameParser : NSObject {
    NSMutableArray *_currenList;
    NSMutableString *_currentResult;
    BOOL _inStream;
    BOOL _publishStream;
    NSString *_streamId;
    BOOL _bold;
    BOOL _mono;
}


-(id)initWithContext:(GameContext *)context;

@property (atomic, strong) RACReplaySubject *subject;

@property (nonatomic, strong) RACReplaySubject *vitals;
@property (nonatomic, strong) RACReplaySubject *room;
@property (nonatomic, strong) RACReplaySubject *exp;
@property (nonatomic, strong) RACReplaySubject *thoughts;
@property (nonatomic, strong) RACReplaySubject *arrivals;
@property (nonatomic, strong) RACReplaySubject *deaths;
@property (nonatomic, strong) RACReplaySubject *familiar;
@property (nonatomic, strong) RACReplaySubject *log;
@property (nonatomic, strong) RACReplaySubject *roundtime;

-(void) parse:(NSString*)data then:(CompleteBlock)block;

@end
