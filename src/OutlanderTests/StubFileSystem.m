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
    _givenFileName = path;
    return _fileContents;
};

- (BOOL)write:(NSString *)data toFile:(NSString *)path {
    _givenFileName = path;
    _fileContents = data;
    return _writeResult;
}

- (BOOL)fileExists:(NSString *)path {
    return _fileExistsResult;
}

@end
