//
//  VariableReplacer.m
//  Outlander
//
//  Created by Joseph McBride on 5/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "VariableReplacer.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Alias.h"
#import "NSString+Categories.h"
#import "Outlander-Swift.h"

@implementation VariableReplacer

- (NSString *)replace:(NSString *)data withContext:(GameContext *)context {
    data = [self replaceGlobalVar:data withContext:context];
    data = [self replaceAlias:data withContext:context];
    return data;
}

- (NSString *)replaceGlobalVar:(NSString *)data withContext:(GameContext *)context {
    return [self replaceVars:data withDict:context.globalVars andPattern:@"\\$([a-zA-z0-9\\.]+)"];
}

- (NSString *)replaceAlias:(NSString *)data withContext:(GameContext *)context {
    
    NSMutableString *str = [data mutableCopy];
    
    [context.aliases enumerateObjectsUsingBlock:^(Alias *obj, NSUInteger idx, BOOL *stop) {
        
        NSString *pattern = [NSString stringWithFormat:@"\\b%@\\b", obj.pattern];
        
        [self replace:str withTemplate:obj.replace andPattern:pattern];
    }];
    
    return str;
}

- (NSString *)replaceLocalVars:(NSString *)data withVars:(TSMutableDictionary *)dict {
    return [self replaceVars:data withDict:dict andPattern:@"\\%([a-zA-z0-9\\.]+)"];
}

- (NSString *)replaceLocalArgumentVars:(NSString *)data withVars:(TSMutableDictionary *)dict {
    return [self replaceVars:data withDict:dict andPattern:@"\\$([0-9\\.]+)"];
}

- (NSString *)replaceVars:(NSString *)data withDict:(TSMutableDictionary *)dict andPattern:(NSString *)pattern {
    NSMutableString *str = [data mutableCopy];
    
    [[str matchesForPattern:pattern] enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
        
        if(res.numberOfRanges < 2) return;
        
        NSString *value = [dict cacheObjectForKey:[data substringWithRange:[res rangeAtIndex:1]]];
        
        if(!value) return;
        
        NSString *pattern = [[data substringWithRange:[res rangeAtIndex:0]] stringByReplacingOccurrencesOfString:@"$" withString:@"\\$"];
        
        [self replace:str withTemplate:value andPattern:pattern];
    }];
    
    return str;
}

- (void) replace: (NSMutableString *)data withTemplate:(NSString *)template andPattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    [regex replaceMatchesInString:data options:0 range:NSMakeRange(0, [data length]) withTemplate:template];
}
@end
