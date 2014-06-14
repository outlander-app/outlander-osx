//
//  ExecuteBlock.h
//  Outlander
//
//  Created by Joseph McBride on 6/13/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

typedef void (^executeBlock) (id context);
typedef void (^doneBlock) ();

@interface ExecuteBlock : NSObject

@property (nonatomic, strong) executeBlock doExecute;
@property (nonatomic, strong) doneBlock doDone;

- (instancetype)initWith:(void(^)(id block))runBlock;

- (void)run;
- (ExecuteBlock *)execute:(executeBlock)block;
- (ExecuteBlock *)execute:(executeBlock)block with:(doneBlock)done;

@end
