//
//  CommandProcessor.h
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ReactiveCocoa.h"

@protocol CommandProcessor <NSObject>

- (RACSignal *)process:(NSString *)command;

@end
