//
//  MyThumb.h
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Shared.h"

@interface MyThumb : NSView

@property (atomic, strong) CompleteBlock down;
@property (atomic, strong) CompleteBlock up;
@property (atomic, strong) CompleteBlock dragged;

@end
