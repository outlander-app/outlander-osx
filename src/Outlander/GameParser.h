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
#import "LearningRate.h"
#import "PlayerStatusIndicator.h"
#import "Roundtime.h"
#import "SkillExp.h"
#import "TextTag.h"
#import "Vitals.h"

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

@property (atomic, strong) RACSubject *subject;

@property (nonatomic, strong) RACSubject *vitals;
@property (nonatomic, strong) RACSubject *indicators;
@property (nonatomic, strong) RACSubject *room;
@property (nonatomic, strong) RACSubject *directions;
@property (nonatomic, strong) RACSubject *exp;
@property (nonatomic, strong) RACSubject *thoughts;
@property (nonatomic, strong) RACSubject *arrivals;
@property (nonatomic, strong) RACSubject *deaths;
@property (nonatomic, strong) RACSubject *familiar;
@property (nonatomic, strong) RACSubject *log;
@property (nonatomic, strong) RACSubject *roundtime;
@property (nonatomic, strong) RACSubject *spell;

-(void) parse:(NSString*)data then:(CompleteBlock)block;

@end
