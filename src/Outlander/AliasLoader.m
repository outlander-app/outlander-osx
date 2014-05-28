//
//  AliasLoader.m
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AliasLoader.h"
#import "NSString+Categories.h"

@interface AliasLoader () {
    GameContext *_context;
    id<FileSystem> _fileSystem;
}
@end

@implementation AliasLoader

- (id)initWithContext:(GameContext *)context andFileSystem:(id<FileSystem>)fileSystem {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    _fileSystem = fileSystem;
    
    return self;
}

- (void)load {
    NSString *configFile = [_context.pathProvider.profileFolder stringByAppendingPathComponent:@"aliases.cfg"];
    
    NSError *error;
    NSString *data = [_fileSystem stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:&error];
    
    if(!data || error) return;
    
    NSString *pattern = @"^#alias \\{(.*)\\} \\{(.*)\\}$";
    [[data matchesForPattern:pattern] enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
        if(res.numberOfRanges > 1) {
            Alias *hl = [[Alias alloc] init];
            hl.pattern = [data substringWithRange:[res rangeAtIndex:1]];
            hl.replace = [data substringWithRange:[res rangeAtIndex:2]];
            [_context.aliases addObject:hl];
        }
    }];
}

- (void)save {
    NSString *configFile = [_context.pathProvider.profileFolder stringByAppendingPathComponent:@"aliases.cfg"];
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [_context.aliases enumerateObjectsUsingBlock:^(Alias *alias, NSUInteger idx, BOOL *stop) {
        [str appendFormat:@"#alias {%@} {%@}\n", alias.pattern, alias.replace];
    }];
    
    [_fileSystem write:str toFile:configFile];
}

@end
