//
//  LocalFileSysem.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "LocalFileSysem.h"

@implementation LocalFileSysem

- (NSString *)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error {
    return [NSString stringWithContentsOfFile:path encoding:enc error:error];
}

@end
