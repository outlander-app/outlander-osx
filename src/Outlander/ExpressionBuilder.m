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
typedef void (^tokenActionBlock) (NSMutableString *str, id token);

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
    
    NSArray *lines = [data componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSUInteger lastCount = 0;
    
    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
       
        if([line length] == 0)
            return;
        
        NSError *err;
        PKAssembly *result = [_parser parseString:line error:&err];
        
        if(err) {
            NSLog(@"err: %@", [err localizedDescription]);
            *stop = YES;
        }
        
        NSLog(@"Script line result: %@", [result description]);
        
        NSUInteger diff = _parser.tokens.count - lastCount;
        
        for (NSUInteger i=0; i<diff; i++) {
            id<Token> token = _parser.tokens[i];
            token.lineNumber = idx;
        }
    }];
    
    
    return _parser.tokens;
}

-(NSArray *)matchTokens {
    return _parser.match_tokens;
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
    
    MoveToken *var = [[MoveToken alloc] init];
    
    id token = [a pop];
    
    while(token) {
        token = [self tokenOrAtom:token];
        [var.tokens insertObject:token atIndex:0];
        token = [a pop];
    }
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
    
    WaitForToken *container = [[WaitForToken alloc] init];
    
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

- (void)parser:(PKParser *)p didMatchMatchStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    TokenList *tl = [self popTokensToList:a];
   
    id label = [tl.tokens objectAtIndex:0];
    [tl.tokens removeObjectAtIndex:0];
    
    MatchToken *match = [[MatchToken alloc] initWith:tl and:label];
    [_parser.match_tokens addObject:match];
}

- (void)parser:(PKParser *)p didMatchMatchWaitStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    MatchWaitToken *mw = [[MatchWaitToken alloc] init];
    
    PKToken *wait = [a pop];
    
    if(wait) {
        mw.waitTime = [NSNumber numberWithDouble:[wait doubleValue]];
    }
    
    [mw.tokens addObjectsFromArray:_parser.match_tokens];
    [_parser.match_tokens removeAllObjects];
    [_parser.tokens addObject:mw];
}

- (void)parser:(PKParser *)p didMatchExitStmt:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    ExitToken *tok = [[ExitToken alloc] init];
    [_parser.tokens addObject:tok];
}

- (void)parser:(PKParser *)p didMatchNextRoom:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    NextRoomToken *tok = [[NextRoomToken alloc] init];
    [_parser.tokens addObject:tok];
}

- (void)parser:(PKParser *)p didMatchEol:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
}

- (void)parser:(PKParser *)p didMatchLine:(PKAssembly *)a {
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

- (void)parser:(PKParser *)p didMatchRegexLiteral:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    __block BOOL lastWasSymbol = NO;
    
    NSMutableString *tokens = [self popTokensToString:a until:^BOOL(id token) {
        return [token isKindOfClass:[PKToken class]];
    } with:^(NSMutableString *str, PKToken *token) {
        if(token.isSymbol) {
            [str insertString:token.stringValue atIndex:0];
            lastWasSymbol = YES;
        } else {
            NSString *pattern = @"%@ ";
            if(lastWasSymbol) {
                pattern = @"%@";
            }
            [str insertString:[NSString stringWithFormat:pattern, token.stringValue] atIndex:0];
            lastWasSymbol = NO;
        }
    }];
    
    if([tokens hasSuffix:@" "]) {
        [tokens replaceCharactersInRange:NSMakeRange(tokens.length-1, 1) withString:@""];
    }
    
    RegexToken *token = [[RegexToken alloc] initWith:tokens];
    [a push:token];
    
//    id token = [a pop];
//    
//    if([token isKindOfClass:[PKToken class]]) {
//        token = [[RegexToken alloc] initWith:[token stringValue]];
//    }
//    
//    [items insertObject:token atIndex:0];
}

- (id)tokenOrAtom:(id)item {
    
    if(![item conformsToProtocol:@protocol(Token)]) {
        PKToken *rhToken = item;
        item = [[Atom alloc] initWith:rhToken.stringValue];
    }
    
    return item;
}

- (TokenList *)popTokensToList:(PKAssembly *)a {
    TokenList *tl = [[TokenList alloc] init];
    
    id token = [a pop];
    
    while (token) {
        [tl.tokens insertObject:token atIndex:0];
        token = [a pop];
    }
    
    return tl;
}

- (NSMutableString *)popTokensToString:(PKAssembly *)a until:(tokenFilterBlock)block {
    return [self popTokensToString:a until:block with:nil];
}

- (NSMutableString *)popTokensToString:(PKAssembly *)a until:(tokenFilterBlock)until with:(tokenActionBlock)action {
    
    if(!action) {
        action = ^(NSMutableString *str, id token){
            [str insertString:[token stringValue] atIndex:0];
        };
    }
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    id token = [a pop];
    
    while(token) {
        BOOL valid = until(token);
        
        if(valid) {
            action(str, token);
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
