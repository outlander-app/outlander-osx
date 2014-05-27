//
//  CommandHandler.h
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@protocol CommandHandler <NSObject>

- (BOOL)canHandle:(NSString *)command;
- (void)handle:(NSString *)command;

@end
