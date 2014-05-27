//
//  CommandProcessor.h
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ReactiveCocoa.h"
#import "TextTag.h"
#import "CommandContext.h"

@protocol CommandProcessor <NSObject>

@property (nonatomic, strong) RACSignal *processed;
@property (nonatomic, strong) RACSignal *echoed;

- (void)process:(CommandContext *)command;
- (void)echo:(TextTag *)tag;

@end
