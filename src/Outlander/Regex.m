//
//  Regex.m
//  Outlander
//
//  Created by Joseph McBride on 2/25/19.
//  Copyright © 2019 Joe McBride. All rights reserved.
//

#import "Regex.h"

static NSMutableDictionary *_cache;

@implementation Regex

+(NSArray<NSTextCheckingResult *> *) matchesForString:(NSString *)value with:(NSString *)pattern {

    if (!_cache) _cache = [[NSMutableDictionary alloc] init];

    NSRegularExpression *regex = [_cache objectForKey:pattern];

    if (regex == nil) {

        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                          options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                            error:&error];
        if(error) {
            NSLog(@"matchesFor Error: %@", [error localizedDescription]);
            return nil;
        }

        _cache[pattern] = regex;
    }

    return [regex matchesInString:value options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [value length])];
}

@end
