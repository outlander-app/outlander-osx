//
//  GameParser.h
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RACSignal.h"
#import "RACReplaySubject.h"
#import "TSMutableDictionary.h"
#import "Shared.h"

@interface GameParser : NSObject {
    NSMutableArray *_currenList;
    NSMutableString *_currentResult;
    BOOL _inStream;
    BOOL _publishStream;
    NSString *_streamId;
    BOOL _bold;
    BOOL _mono;
}

@property (atomic, strong) RACReplaySubject *subject;
@property (atomic, strong) TSMutableDictionary *globalVars;
-(void) parse:(NSString*)data then:(CompleteBlock)block;

@end
