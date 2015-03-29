//
//  GameCommandRelay.m
//  Outlander
//
//  Created by Joseph McBride on 5/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameCommandRelay.h"

@implementation GameCommandRelay

- (void)sendCommand:(CommandContext *)ctx {
    
    NSDictionary *userInfo = @{@"command": ctx};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OL:command"
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)sendEcho:(TextTag *)tag {
    
    NSDictionary *userInfo = @{@"tag": tag};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OL:echo"
                                                        object:nil
                                                      userInfo:userInfo];
}

@end
