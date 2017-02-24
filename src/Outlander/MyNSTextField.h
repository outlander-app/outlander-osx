//
//  MyNSTextField.h
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface MyNSTextField : NSTextField

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) int maxHistoryLength;

- (void)configure;
- (void)commitHistory;
- (void)previousHistory;
- (void)nextHistory;
- (BOOL)hasFocus;

@end
