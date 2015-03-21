//
//  Shared.h
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

typedef void (^CompleteBlock)(id);
typedef BOOL (^PredicateBlock)(id);

@protocol InfoStream <NSObject>

@property (atomic, strong) RACMulticastConnection *subject;
@property (atomic, strong) RACMulticastConnection *room;
@property (atomic, strong) RACMulticastConnection *spell;

@end
