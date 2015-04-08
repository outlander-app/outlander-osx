//
//  MacrosLoader.m
//  Outlander
//
//  Created by Joseph McBride on 6/19/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MacrosLoader.h"
#import "NSString+Categories.h"
#import "OUtlander-Swift.h"

@interface MacrosLoader () {
    GameContext *_context;
    id<FileSystem> _fileSystem;
}
@end

@implementation MacrosLoader

- (id)initWithContext:(GameContext *)context andFileSystem:(id<FileSystem>)fileSystem {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    _fileSystem = fileSystem;
    
    return self;
}

- (void)load {
    NSString *configFile = [_context.pathProvider.profileFolder stringByAppendingPathComponent:@"macros.cfg"];
    
    NSError *error;
    NSString *data = [_fileSystem stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:&error];
    
    if(!data || error) return;
    
    NSString *pattern = @"^#macro \\{(.*)\\} \\{(.*)\\}$";
    [[data matchesForPattern:pattern] enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
        if(res.numberOfRanges > 1) {
            Macro *m = [[Macro alloc] init];
            NSString *keys = [data substringWithRange:[res rangeAtIndex:1]];
            m.keys = keys;
            m.action = [data substringWithRange:[res rangeAtIndex:2]];
            [_context.macros addObject:m];
        }
    }];
}

- (void)save {
    NSString *configFile = [_context.pathProvider.profileFolder stringByAppendingPathComponent:@"macros.cfg"];
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [_context.macros enumerateObjectsUsingBlock:^(Macro *m, NSUInteger idx, BOOL *stop) {
        [str appendFormat:@"#macro {%@} {%@}\n", m.keys, m.action != nil ? m.action : @""];
    }];
    
    [_fileSystem write:str toFile:configFile];
}

@end