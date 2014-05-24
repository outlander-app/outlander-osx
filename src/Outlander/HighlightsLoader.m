//
//  HighlightsLoader.m
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "HighlightsLoader.h"
#import "ReactiveCocoa.h"
#import "NSString+Categories.h"

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
    [[data matchesForPattern:pattern] enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
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

@end
