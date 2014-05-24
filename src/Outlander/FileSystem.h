//
//  FileSystem.h
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@protocol FileSystem <NSObject>

- (NSString *)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
- (BOOL)write:(NSString *)data toFile:(NSString *)path;

@end
