//
//  EventRelay.h
//  Outlander
//
//  Created by Joseph McBride on 5/31/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@protocol EventRelay <NSObject>

- (void)send:(NSString *)event with:(NSDictionary *)data;

@end
