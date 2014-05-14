//
//  Vitals.h
//  Outlander
//
//  Created by Joseph McBride on 1/30/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface Vitals : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) UInt16 value;

-(id)initWith:(NSString*)name value:(UInt16)value;

@end
