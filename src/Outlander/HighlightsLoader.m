//
//  HighlightsLoader.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "HighlightsLoader.h"
#import "ReactiveCocoa.h"

@interface HighlightsLoader () {
    GameContext *_context;
    id<FileSystem> _fileSystem;
}
@end

@implementation HighlightsLoader

- (id)initWithContext:(GameContext *)context andFileSystem:(id<FileSystem>)fileSystem {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    _fileSystem = fileSystem;
    
    return self;
}

- (void)load {
    NSString *configFile = [_context.pathProvider.profileFolder stringByAppendingPathComponent:@"highlights.cfg"];
    
    NSError *error;
    NSString *data = [_fileSystem stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:&error];
    
    if(!data || error) return;
    
    NSString *pattern = @"^#highlight \\{(.*)\\} \\{(.*)\\}$";
    [[self matchesFor:data pattern:pattern] enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
        NSLog(@"ranges: %lu", (unsigned long)res.numberOfRanges);
        if(res.numberOfRanges > 1) {
            Highlight *hl = [[Highlight alloc] init];
            hl.color = [data substringWithRange:[res rangeAtIndex:1]];
            hl.pattern = [data substringWithRange:[res rangeAtIndex:2]];
            [_context.highlights addObject:hl];
        }
    }];
}

- (void)save {
}

- (NSArray *)matchesFor:(NSString *)data pattern:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    if(error) {
        NSLog(@"matchesFor Error: %@", [error localizedDescription]);
        return nil;
    }
    
    NSArray *matches = [regex matchesInString:data options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [data length])];
    return matches;
}

@end
