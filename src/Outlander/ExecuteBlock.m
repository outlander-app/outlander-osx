//
//  ExecuteBlock.m
//  Outlander
//
//  Created by Joseph McBride on 6/13/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ExecuteBlock.h"

@interface ExecuteBlock () {
    void(^_run)(id block);
}
@end

@implementation ExecuteBlock

- (instancetype)initWith:(void(^)(id block))runBlock {
    self = [super init];
    if(!self) return nil;
    
    _run = runBlock;
    
    return self;
}

- (void)run {
    _run(self);
}

-(ExecuteBlock *)execute:(executeBlock)block {
    _doExecute = block;
    return self;
}

-(ExecuteBlock *)execute:(executeBlock)block with:(doneBlock)done {
    _doExecute = block;
    _doDone = done;
    
    return self;
}

@end
