//
//  LocalFileSysem.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "LocalFileSystem.h"

@implementation LocalFileSystem

- (NSString *)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error {
    return [NSString stringWithContentsOfFile:path encoding:enc error:error];
}

- (BOOL)write:(NSString *)data toFile:(NSString *)path {
    NSData *bits = [data dataUsingEncoding:NSUTF8StringEncoding];
    return [bits writeToFile:path atomically:YES];
}

- (BOOL)fileExists:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

@end
