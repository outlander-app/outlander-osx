//
//  Actor.m
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Actor.h"

@interface Actor ()
@property (nonatomic, strong, readonly) NSCondition *condition;
@property (nonatomic, assign) BOOL paused;
@end

@implementation Actor

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _uuid = [[NSUUID UUID] UUIDString];
    _condition = [[NSCondition alloc] init];
    
    return self;
}

- (void)cancel {
    
    [super cancel];
    
    if (_paused) {
        _paused = NO;
        [_condition signal];
    }
}

- (BOOL)isPaused {
    return _paused;
}

- (void)suspend {
    NSLog(@"%@ :: suspending", [self description]);
    _paused = YES;
}

- (void)resume {
    NSLog(@"%@ :: resuming", [self description]);
    _paused = NO;
    [_condition signal];
}

- (void)main {
    @autoreleasepool {
        
        BOOL shouldKeepRunning = YES;
        
        NSLog(@"%@ :: starting", [self description]);
        
        while (shouldKeepRunning && !self.isCancelled) {
            
            [_condition lock];
            
            while(_paused) {
                NSLog(@"%@ :: waiting", [self description]);
                [_condition wait];
            }
            
            if(!self.isCancelled){
                [self process];
            }
            
            [_condition unlock];
        }
        
        NSLog(@"%@ :: Script completed: %hhd", [self description], self.isCancelled);
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %p %@", NSStringFromClass([self class]), self, self.uuid];
}

- (void)process {
    NSLog(@"%@ :: running", [self description]);
    
    NSTimeInterval interval = 2.0;
    [NSThread sleepForTimeInterval:interval];
}

@end
