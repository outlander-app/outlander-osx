//
//  TextTag.h
//  Outlander
//
//  Created by Joseph McBride on 1/25/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface TextTag : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *backgroundColor;
@property (nonatomic, copy) NSString *href;
@property (nonatomic, copy) NSString *command;
@property (nonatomic, assign) BOOL mono;
@property (nonatomic, assign) BOOL bold;

- initWith:(NSString*)text mono:(BOOL)mono;
+ tagFor:(NSString*)text mono:(BOOL)mono;

@end
