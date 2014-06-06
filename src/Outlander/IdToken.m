//
//  IdToken.m
//  Outlander
//
//  Created by Joseph McBride on 6/6/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "IdToken.h"

@interface IdToken () {
    NSString *_val;
}
@end

@implementation IdToken

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
