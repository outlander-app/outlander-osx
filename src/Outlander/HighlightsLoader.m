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
    
    NSString *pattern = @"^#highlight \\{(.*)\\} \\{(.*)\\}$";
    [[data matchesForPattern:pattern] enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
        if(res.numberOfRanges > 1) {
            Highlight *hl = [[Highlight alloc] init];
            NSString *colorsStr = [data substringWithRange:[res rangeAtIndex:1]];
            
            NSArray *colors = [colorsStr componentsSeparatedByString:@","];
            
            hl.color = colors.count > 0 ? [colors[0] trimWhitespace] : @"";
            hl.backgroundColor = colors.count > 1 ? [colors[1] trimWhitespace] : @"";
            hl.pattern = [data substringWithRange:[res rangeAtIndex:2]];
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
        
        [str appendFormat:@"#highlight {%@} {%@}\n", colors, hl.pattern];
    }];
    
    [_fileSystem write:str toFile:configFile];
}

@end
