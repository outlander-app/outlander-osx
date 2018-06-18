//
//  NSString+Files.m
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "NSString+Categories.h"

@implementation NSString (Categories)

+ (NSDateFormatter*) dateFormatter {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _specialFormatting = [[NSDateFormatter alloc] init];
    });
    return _specialFormatting;
}

- (BOOL) appendToFile:(NSString *)path encoding:(NSStringEncoding)enc {
    BOOL result = YES;
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if ( !fh ) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    if ( !fh ) return NO;
    @try {
        [fh seekToEndOfFile];
        [fh writeData:[self dataUsingEncoding:enc]];
    }
    @catch (NSException * e) {
        result = NO;
    }
    [fh closeFile];
    return result;
}

- (BOOL) containsString: (NSString*) substring {
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

- (NSString*) stringFromDateFormat: (NSString*) dateFormat {
    NSDateFormatter *formatter = NSString.dateFormatter;
    [formatter setDateFormat:dateFormat];
    
    return [NSString stringWithFormat:self, [formatter stringFromDate:[NSDate date]]];
}

- (NSString*) trimNewLine {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (NSString*) trimWhitespaceAndNewline {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString*) trimWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSArray *)matchesForPattern:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    if(error) {
        NSLog(@"matchesFor Error: %@", [error localizedDescription]);
        return nil;
    }
    
    NSArray *matches = [regex matchesInString:self options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [self length])];
    return matches;
}

-(NSString *) replaceWithPattern:(NSString *)pattern andTemplate:(NSString *)template {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, [self length])
                                      withTemplate:template];
}

- (NSArray*) splitToCommands {

    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSArray *matches = [self matchesForPattern:@"((?<!\\\\);)"];
    
    __block NSUInteger lastIndex = 0;

    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
        NSString *str = [self substringWithRange:NSMakeRange(lastIndex, res.range.location - lastIndex)];
        str = [str stringByReplacingOccurrencesOfString:@"\\;" withString:@";"];
        [results addObject:str];
        lastIndex = res.range.location + res.range.length;
    }];
    
    NSUInteger length = [self length];
    
    if(lastIndex < length) {
        NSString *str = [self substringWithRange:NSMakeRange(lastIndex, length - lastIndex)];
        str = [str stringByReplacingOccurrencesOfString:@"\\;" withString:@";"];
        [results addObject:str];
    }
    
    return results;
}
@end
