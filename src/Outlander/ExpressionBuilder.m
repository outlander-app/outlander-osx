//
//  ExpressionBuilder.m
//  Outlander
//
//  Created by Joseph McBride on 6/4/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ExpressionBuilder.h"
#import <PEGKit/PEGKit.h>
#import "ExpressionParser.h"

typedef BOOL (^tokenFilterBlock) (PKToken *token);

@interface ExpressionBuilder () {
    ExpressionParser *_parser;
}
@end

@implementation ExpressionBuilder

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
   
    _parser = [[ExpressionParser alloc] initWithDelegate:self];
    
    return self;
}

-(NSArray *)build:(NSString *)data {
    NSError *err;
    PKAssembly *result = [_parser parseString:data error:&err];
    
    if(err) {
        NSLog(@"err: %@", [err localizedDescription]);
        return nil;
    }
    
    NSLog(@"Script line result: %@", [result description]);
    
    return _parser.tokens;
}

- (void)parser:(PKParser *)p didMatchLocalVar:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    NSArray *ids = @[@"$", @"%"];
    
    NSString *tokens = [self popTokensToString:a until:^BOOL(PKToken *token) {
        return [ids containsObject:token.stringValue];
    }];
    
    VarToken *var = [[VarToken alloc] initWith:tokens];
    [a push:var];
}

- (void)parser:(PKParser *)p didMatchAssignment:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    id rh = [a pop];
    NSString *lh = [self popTokensToString:a until:^BOOL(PKToken *token) {
        return false;
    }];

    rh = [self tokenOrAtom:rh];
    
    AssignmentToken *token = [[AssignmentToken alloc] initWith:rh and:[[Atom alloc] initWith:lh]];
    [_parser.tokens addObject:token];
}

- (void)parser:(PKParser *)p didMatchLabel:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    NSString *tokens = [self popTokensToString:a until:^BOOL(PKToken *token) {
        return false;
    }];
    
    LabelToken *var = [[LabelToken alloc] initWith:tokens];
    [_parser.tokens addObject:var];
}

- (void)parser:(PKParser *)p didMatchPutStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PutToken *put = [[PutToken alloc] init];
    
    id token = [a pop];
    
    while(token) {
        token = [self tokenOrAtom:token];
        [put.tokens insertObject:token atIndex:0];
        token = [a pop];
    }
    
    [_parser.tokens addObject:put];
}

- (void)parser:(PKParser *)p didMatchEol:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
}

- (id)tokenOrAtom:(id)item {
    
    if(![item conformsToProtocol:@protocol(Token)]) {
        PKToken *rhToken = item;
        item = [[Atom alloc] initWith:rhToken.stringValue];
    }
    
    return item;
}

- (NSMutableString *)popTokensToString:(PKAssembly *)a until:(tokenFilterBlock)block {
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    PKToken *token = [a pop];
    
    while(token) {
        BOOL stop = block(token);
        
        [str insertString:token.stringValue atIndex:0];
        
        if(stop) break;
        token = [a pop];
    }
    
    return str;
}

@end
