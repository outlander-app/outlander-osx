//
//  HighlightsLoader.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "HighlightsLoader.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSString+Categories.h"
#import "Outlander-Swift.h"
#import "Regex.h"

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
    
    [_context.highlights removeAll];
    
    NSString *pattern = @"^#highlight \\{(.*?)\\} \\{(.*?)\\}(?:\\s\\{(.*?)\\})?(?:\\s\\{(.*?)\\})?$";

    [[Regex matchesForString:data with:pattern] enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
        if(res.numberOfRanges > 1) {
            Highlight *hl = [[Highlight alloc] init];
            NSString *colorsStr = [data substringWithRange:[res rangeAtIndex:1]];
            
            NSArray *colors = [colorsStr componentsSeparatedByString:@","];
            
            hl.color = colors.count > 0 ? [colors[0] trimWhitespace] : @"";
            hl.backgroundColor = colors.count > 1 ? [colors[1] trimWhitespace] : @"";
            hl.pattern = [data substringWithRange:[res rangeAtIndex:2]];

            if (res.numberOfRanges > 3 && [res rangeAtIndex:3].location != NSNotFound) {
                hl.filterClass = [data substringWithRange:[res rangeAtIndex:3]];
            }

            if (res.numberOfRanges > 4 && [res rangeAtIndex:4].location != NSNotFound) {
                hl.soundFile = [data substringWithRange:[res rangeAtIndex:4]];
            }
            
            [_context.highlights addObject:hl];
        }
    }];
}

- (void)save {
    NSString *configFile = [_context.pathProvider.profileFolder stringByAppendingPathComponent:@"highlights.cfg"];
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [_context.highlights enumerateObjectsUsingBlock:^(Highlight *hl, NSUInteger idx, BOOL *stop) {
        
        NSMutableString *colors = [[NSMutableString alloc] initWithString:hl.color];
        
        if (hl.backgroundColor != nil && [hl.backgroundColor length] > 0) {
            [colors appendFormat:@",%@", hl.backgroundColor];
        }

        NSString *filterClass = @"";

        if(hl.filterClass != nil && ![hl.filterClass isEqualToString:@""]) {
            filterClass = [NSString stringWithFormat:@" {%@}", hl.filterClass];
        }

        NSString *soundFile = @"";
        if(hl.soundFile != nil && ![hl.soundFile isEqualToString:@""]) {
            soundFile = [NSString stringWithFormat:@" {%@}", hl.soundFile];

            if([filterClass isEqualToString:@""]) {
                filterClass = @" {}";
            }
        }
        
        [str appendFormat:@"#highlight {%@} {%@}%@%@\n", colors, hl.pattern, filterClass, soundFile];
    }];
    
    [_fileSystem write:str toFile:configFile];
}

@end
