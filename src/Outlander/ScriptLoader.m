//
//  ScriptLoader.m
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ScriptLoader.h"
#import "NSString+Categories.h"

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
    
    NSError *err;
    NSString *data = [_fileSystem stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&err];
    
    if(err) {
        NSLog(@"Error loading script: %@", [err localizedDescription]);
    }
    
    return data;
}

@end
