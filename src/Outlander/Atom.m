//
//  Atom.m
//  Outlander
//
//  Created by Joseph McBride on 6/5/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Atom.h"

@interface Atom () {
    NSString *_val;
}
@end

@implementation Atom

- (instancetype)initWith:(NSString *)val {
    self = [super init];
    if(!self) return nil;
    
    _val = val;
    
    return self;
}

- (id)eval {
    return _val;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", [super description], _val];
}

@end
