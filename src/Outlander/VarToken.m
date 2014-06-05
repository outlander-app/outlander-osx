//
//  VarToken.m
//  Outlander
//
//  Created by Joseph McBride on 6/4/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "VarToken.h"

@interface VarToken () {
    NSString *_val;
}
@end

@implementation VarToken

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
