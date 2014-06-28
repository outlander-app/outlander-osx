//
//  RountimeNotifier.h
//  Outlander
//
//  Created by Joseph McBride on 5/17/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GameContext.h"

@interface RoundtimeNotifier : NSObject

@property (nonatomic, strong) RACSubject *notification;

- (instancetype)initWith:(GameContext *)context;
- (void)set:(NSInteger)value;

@end
