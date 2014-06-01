//
//  GameEventRelay.m
//  Outlander
//
//  Created by Joseph McBride on 5/31/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameEventRelay.h"

@implementation GameEventRelay

- (void)send:(NSString *)event with:(NSDictionary *)data {
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:event
                      object:self
                    userInfo:data];
}

@end
