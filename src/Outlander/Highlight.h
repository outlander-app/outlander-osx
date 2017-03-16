//
//  Highlight.h
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@interface Highlight : NSObject

@property (nonatomic, strong, nullable) NSString *pattern;
@property (nonatomic, strong, nullable) NSString *color;
@property (nonatomic, strong, nullable) NSString *backgroundColor;
@property (nonatomic, strong, nullable) NSString *filterClass;

@end
