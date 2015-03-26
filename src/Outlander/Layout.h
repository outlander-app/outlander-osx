//
//  Layout.h
//  Outlander
//
//  Created by Joseph McBride on 3/25/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "WindowData.h"

@interface Layout : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) WindowData *primaryWindow;
@property (nonatomic, strong) NSArray *windows;

@end
