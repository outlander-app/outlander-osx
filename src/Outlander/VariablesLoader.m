//
//  VariablesLoader.m
//  Outlander
//
//  Created by Joseph McBride on 5/23/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "VariablesLoader.h"
#import "NSString+Categories.h"
#import "Outlander-Swift.h"

@interface VariablesLoader () {
    GameContext *_context;
    id<FileSystem> _fileSystem;
}
@end

@implementation VariablesLoader

- (id)initWithContext:(GameContext *)context andFileSystem:(id<FileSystem>)fileSystem {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    _fileSystem = fileSystem;
    
    return self;
}

- (void)load {
    NSString *configFile = [_context.pathProvider.profileFolder stringByAppendingPathComponent:@"variables.cfg"];
    
    NSError *error;
    NSString *data = [_fileSystem stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:&error];
    
    if(!data || error) {
        if (_context.globalVars.count == 0) {
            [self setDefaults];
        }
        return;
    }
    
    [_context.globalVars removeAll];
    [self setDefaults];
    
    NSString *pattern = @"^#var \\{(.*)\\} \\{(.*)\\}$";
    [[data matchesForPattern:pattern] enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
        if(res.numberOfRanges > 1) {
            NSString *key = [data substringWithRange:[res rangeAtIndex:1]];
            NSString *value = [data substringWithRange:[res rangeAtIndex:2]];
            [_context.globalVars set:value forKey:key];
        }
    }];
   
    // ensure that roundtime is always zero when reloaded
    [_context.globalVars set:@"0" forKey:@"roundtime"];
}

- (void)setDefaults {
    [_context.globalVars set:@">" forKey: @"prompt"];
    [_context.globalVars set:@"Empty" forKey: @"lefthand"];
    [_context.globalVars set:@"Empty" forKey: @"righthand"];
    [_context.globalVars set:@"None" forKey: @"preparedspell"];
    [_context.globalVars set:@"0" forKey: @"tdp"];
}

- (void)save {
    
    NSString *configFile = [_context.pathProvider.profileFolder stringByAppendingPathComponent:@"variables.cfg"];
    
    NSMutableString *str = [[NSMutableString alloc] init];

    [_context.globalVars.alphabeticalKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"#var {%@} {%@}\n", key, [_context.globalVars get:key]];
    }];

    [_fileSystem write:str toFile:configFile];
}

@end
