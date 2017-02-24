//
//  ScriptLoader.m
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ScriptLoader.h"
#import "NSString+Categories.h"
#import "Outlander-Swift.h"

@interface ScriptLoader () {
    GameContext *_context;
    id<FileSystem> _fileSystem;
}
@end

@implementation ScriptLoader

- (instancetype)initWith:(GameContext *)context and:(id<FileSystem>)fileSystem {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    _fileSystem = fileSystem;
    
    return self;
}

- (NSString *)load:(NSString *)scriptName {
    
    NSString *fileName = [NSString stringWithFormat:@"%@%@", [scriptName trimWhitespaceAndNewline], @".cmd"];
    NSString *file = [_context.pathProvider.scriptsFolder stringByAppendingPathComponent:fileName];

    if (![_fileSystem fileExists:file]) {
        return @"";
    }
    
    NSError *err;
    NSString *data = [_fileSystem stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&err];

    if(err) {
        [_context.events echoText:[NSString stringWithFormat:@"Error loading script: %@", [err localizedDescription]]
                             mono:true
                           preset:@"scripterror"];
    }
    
    return data;
}

- (BOOL)exists:(NSString *)scriptName {

    NSString *fileName = [NSString stringWithFormat:@"%@%@", [scriptName trimWhitespaceAndNewline], @".cmd"];
    NSString *file = [_context.pathProvider.scriptsFolder stringByAppendingPathComponent:fileName];

    return [_fileSystem fileExists:file];
}

@end
