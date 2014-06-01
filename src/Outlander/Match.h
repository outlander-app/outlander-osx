//
//  Match.h
//  Outlander
//
//  Created by Joseph McBride on 5/31/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface Match : NSObject

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL isRegex;

+(instancetype)match:(NSString *)label with:(NSString *)text and:(BOOL)isRegex;
-(instancetype)init:(NSString *)label with:(NSString *)text and:(BOOL)isRegex;

@end
