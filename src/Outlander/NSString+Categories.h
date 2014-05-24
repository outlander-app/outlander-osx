//
//  NSString+Files.h
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Categories)
- (BOOL) appendToFile:(NSString *)path encoding:(NSStringEncoding)enc;
- (BOOL) containsString: (NSString*) substring;
- (NSString*) trimNewLine;
- (NSString*) trimWhitespaceAndNewline;
- (NSString*) stringFromDateFormat: (NSString*) dateFormat;
- (NSArray *)matchesForPattern:(NSString *)pattern;
@end
