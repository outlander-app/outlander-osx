//
//  Script.m
//  Outlander
//
//  Created by Joseph McBride on 5/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Script.h"
#import "TSMutableDictionary.h"
#import <PEGKit/PEGKit.h>
#import "OutlanderParser.h"

@interface Script () {
    OutlanderParser *_parser;
    NSMutableArray *_scriptLines;
}

@property (nonatomic, strong) TSMutableDictionary *labels;
@property (nonatomic, strong) TSMutableDictionary *localVars;
@property (nonatomic, assign) NSUInteger lineNumber;

@end

@implementation Script

- (instancetype) init {
    self = [super init];
    if(!self) return nil;
    
    _labels = [[TSMutableDictionary alloc] initWithName:[NSString stringWithFormat:@"com.outlander.script.labels.%@", self.uuid]];
    _localVars = [[TSMutableDictionary alloc] initWithName:[NSString stringWithFormat:@"com.outlander.script.localvars.%@", self.uuid]];
    
    _parser = [[OutlanderParser alloc] initWithDelegate:self];
    _scriptLines = [[NSMutableArray alloc] init];
    
    _lineNumber = 0;
   
    [_scriptLines addObject:@"start:"];
    [_scriptLines addObject:@"put look"];
    [_scriptLines addObject:@"pause 3"];
    [_scriptLines addObject:@"goto start"];
    
    return self;
}

- (void)process {
    NSLog(@"%@ :: script running", [self description]);
    
    if(_lineNumber >= _scriptLines.count) {
        NSLog(@"End of script!");
        [self cancel];
        return;
    }
    
    NSString *line = _scriptLines[_lineNumber];
   
    NSError *err;
    PKAssembly *result = [_parser parseString:line error:&err];
    
    if(err) {
        NSLog(@"err: %@", [err localizedDescription]);
        [self cancel];
        return;
    }
    
    NSLog(@"Script line result: %@", [result description]);
    
    _lineNumber++;
}

- (void)parser:(PKParser *)p didMatchPutStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    NSMutableString *putString = [[NSMutableString alloc] init];
    
    PKToken *token = [a pop];
    
    while(token) {
        
        [putString insertString:[NSString stringWithFormat:@"%@ ", [token stringValue]]
                        atIndex:0];
        
        token = [a pop];
    }
    
    NSLog(@"putting: %@", putString);
}

- (void)parser:(PKParser *)p didMatchPauseStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    NSNumber *time = [a pop];
    if(!time) {
        time = @1.0;
    }
    
    NSTimeInterval interval = [time doubleValue];
    NSLog(@"pausing for %f", interval);
    
    [NSThread sleepForTimeInterval:interval];
}

- (void)parser:(PKParser *)p didMatchLabelStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *label = [a pop];
    
    NSLog(@"Label: %@", [label stringValue]);
    
    [_labels setCacheObject:@(_lineNumber) forKey:[label stringValue]];
}

- (void)parser:(PKParser *)p didMatchGotoStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *label = [a pop];
    
    NSLog(@"goto: %@", [label stringValue]);
    
    NSNumber *gotoObj = [_labels cacheObjectForKey:[label stringValue]];
    
    if(!gotoObj) {
        NSLog(@"Unknown label %@", [label stringValue]);
        [self cancel];
        return;
    }
    
    _lineNumber = [gotoObj integerValue];
}

@end
