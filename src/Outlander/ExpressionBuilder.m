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

typedef BOOL (^tokenFilterBlock) (id token);

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
    
    NSString *str = [self popTokensToString:a until:^BOOL(id token) {
        return [token isKindOfClass:[PKToken class]];
    }];
    
    if([str length] == 0) {
        IdToken *idTok = [a pop];
        str = [idTok eval];
    }
    
    VarToken *var = [[VarToken alloc] initWith:str];
    [a push:var];
}

- (void)parser:(PKParser *)p didMatchAssignment:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    id rh = [a pop];
    id lh = [a pop];
    
    AssignmentToken *token = [[AssignmentToken alloc] initWith:rh and:lh];
    [_parser.tokens addObject:token];
}

- (void)parser:(PKParser *)p didMatchLabel:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    IdToken *idtoken = [a pop];
    
    LabelToken *var = [[LabelToken alloc] initWith:[idtoken eval]];
    [_parser.tokens addObject:var];
}

- (void)parser:(PKParser *)p didMatchId:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    NSString *str = [self popTokensToString:a until:^BOOL(id token) {
        return [token isKindOfClass:[PKToken class]];
    }];
   
    IdToken *idToken = [[IdToken alloc] initWith:str];
    [a push:idToken];
}

- (void)parser:(PKParser *)p didMatchGotoStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    id rh = [a pop];
    rh = [self tokenOrAtom:rh];
    
    GotoToken *var = [[GotoToken alloc] initWith:rh];
    [_parser.tokens addObject:var];
}

- (void)parser:(PKParser *)p didMatchMoveStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    id rh = [a pop];
    rh = [self tokenOrAtom:rh];
    
    MoveToken *var = [[MoveToken alloc] initWith:rh];
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

- (void)parser:(PKParser *)p didMatchWaitForStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    WaitToken *container = [[WaitToken alloc] init];
    
    id token = [a pop];
    
    while(token) {
        token = [self tokenOrAtom:token];
        [container.tokens insertObject:token atIndex:0];
        token = [a pop];
    }
    
    [_parser.tokens addObject:container];
}

- (void)parser:(PKParser *)p didMatchEchoStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    EchoToken *put = [[EchoToken alloc] init];
    
    id token = [a pop];
    
    while(token) {
        token = [self tokenOrAtom:token];
        [put.tokens insertObject:token atIndex:0];
        token = [a pop];
    }
    
    [_parser.tokens addObject:put];
}

- (void)parser:(PKParser *)p didMatchPause:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *num = [a pop];
    
    double val = 1.0;
    
    if(num){
        val = [num doubleValue];
    }
    
    NSNumber *number = [NSNumber numberWithDouble:val];
    
    PauseToken *token = [[PauseToken alloc] initWith:number];
    [_parser.tokens addObject:token];
}

- (void)parser:(PKParser *)p didMatchEol:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
}

- (void)parser:(PKParser *)p didMatchAtom:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    id token = [a pop];
    
    if([token isKindOfClass:[PKToken class]]) {
        token = [[Atom alloc] initWith:[token stringValue]];
    }
    
    [a push:token];
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
    
    id token = [a pop];
    
    while(token) {
        BOOL valid = block(token);
        
        if(valid) {
            [str insertString:[token stringValue] atIndex:0];
            token = [a pop];
        }
        else {
            [a push:token];
            break;
        }
    }
    
    return str;
}

@end
