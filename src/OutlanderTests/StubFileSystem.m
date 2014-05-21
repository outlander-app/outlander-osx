//
//  StubFileSystem.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "StubFileSystem.h"

@implementation StubFileSystem

- (NSString *)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError *__autoreleasing *)error {
    return _fileContents;
};

@end
