//
//  NSString+Files.h
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Categories)
+ (NSDateFormatter*) dateFormatter;

- (BOOL) appendToFile:(NSString *)path encoding:(NSStringEncoding)enc;
- (BOOL) containsString: (NSString *) substring;
- (NSString *) trimNewLine;
- (NSString *) trimWhitespace;
- (NSString *) trimWhitespaceAndNewline;
- (NSString *) stringFromDateFormat: (NSString *) dateFormat;
- (NSArray  *) matchesForPattern:(NSString *)pattern;
- (NSString *) replaceWithPattern:(NSString *)pattern andTemplate:(NSString *)template;
- (NSArray*) splitToCommands;
@end
