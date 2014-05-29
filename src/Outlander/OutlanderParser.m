#import "OutlanderParser.h"
#import <PEGKit/PEGKit.h>

#define LT(i) [self LT:(i)]
#define LA(i) [self LA:(i)]
#define LS(i) [self LS:(i)]
#define LF(i) [self LD:(i)]

#define POP()        [self.assembly pop]
#define POP_STR()    [self popString]
#define POP_TOK()    [self popToken]
#define POP_BOOL()   [self popBool]
#define POP_INT()    [self popInteger]
#define POP_DOUBLE() [self popDouble]

#define PUSH(obj)      [self.assembly push:(id)(obj)]
#define PUSH_BOOL(yn)  [self pushBool:(BOOL)(yn)]
#define PUSH_INT(i)    [self pushInteger:(NSInteger)(i)]
#define PUSH_DOUBLE(d) [self pushDouble:(double)(d)]

#define EQ(a, b) [(a) isEqual:(b)]
#define NE(a, b) (![(a) isEqual:(b)])
#define EQ_IGNORE_CASE(a, b) (NSOrderedSame == [(a) compare:(b)])

#define MATCHES(pattern, str)               ([[NSRegularExpression regularExpressionWithPattern:(pattern) options:0                                  error:nil] numberOfMatchesInString:(str) options:0 range:NSMakeRange(0, [(str) length])] > 0)
#define MATCHES_IGNORE_CASE(pattern, str)   ([[NSRegularExpression regularExpressionWithPattern:(pattern) options:NSRegularExpressionCaseInsensitive error:nil] numberOfMatchesInString:(str) options:0 range:NSMakeRange(0, [(str) length])] > 0)

#define ABOVE(fence) [self.assembly objectsAbove:(fence)]

#define LOG(obj) do { NSLog(@"%@", (obj)); } while (0);
#define PRINT(str) do { printf("%s\n", (str)); } while (0);

@interface PKParser ()
//@property (nonatomic, retain) NSMutableDictionary *tokenKindTab;
//@property (nonatomic, retain) NSMutableArray *tokenKindNameTab;
//@property (nonatomic, retain) NSString *startRuleName;
//@property (nonatomic, retain) NSString *statementTerminator;
//@property (nonatomic, retain) NSString *singleLineCommentMarker;
//@property (nonatomic, retain) NSString *blockStartMarker;
//@property (nonatomic, retain) NSString *blockEndMarker;
//@property (nonatomic, retain) NSString *braces;

- (BOOL)popBool;
- (NSInteger)popInteger;
- (double)popDouble;
- (PKToken *)popToken;
- (NSString *)popString;

- (void)pushBool:(BOOL)yn;
- (void)pushInteger:(NSInteger)i;
- (void)pushDouble:(double)d;
@end

@interface OutlanderParser ()
@property (nonatomic, retain) NSMutableDictionary *program_memo;
@property (nonatomic, retain) NSMutableDictionary *name_memo;
@property (nonatomic, retain) NSMutableDictionary *numberLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *stringLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *stmts_memo;
@property (nonatomic, retain) NSMutableDictionary *stmt_memo;
@property (nonatomic, retain) NSMutableDictionary *commands_memo;
@property (nonatomic, retain) NSMutableDictionary *commandExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *setVar_memo;
@property (nonatomic, retain) NSMutableDictionary *putLiterals_memo;
@property (nonatomic, retain) NSMutableDictionary *putExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *commandsStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *putStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *pauseStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *labelStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *gotoStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *varStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *nameExprPair_memo;
@end

@implementation OutlanderParser

- (id)initWithDelegate:(id)d {
    self = [super initWithDelegate:d];
    if (self) {
        self.startRuleName = @"program";
        self.enableAutomaticErrorRecovery = YES;

        self.tokenKindTab[@"script"] = @(OUTLANDERPARSER_TOKEN_KIND_SCRIPT);
        self.tokenKindTab[@"alias"] = @(OUTLANDERPARSER_TOKEN_KIND_ALIAS);
        self.tokenKindTab[@"put"] = @(OUTLANDERPARSER_TOKEN_KIND_PUT);
        self.tokenKindTab[@"#"] = @(OUTLANDERPARSER_TOKEN_KIND_POUND);
        self.tokenKindTab[@"goto"] = @(OUTLANDERPARSER_TOKEN_KIND_GOTO);
        self.tokenKindTab[@"="] = @(OUTLANDERPARSER_TOKEN_KIND_EQUALS);
        self.tokenKindTab[@"var"] = @(OUTLANDERPARSER_TOKEN_KIND_VAR);
        self.tokenKindTab[@"highlight"] = @(OUTLANDERPARSER_TOKEN_KIND_HIGHLIGHT);
        self.tokenKindTab[@"setvariable"] = @(OUTLANDERPARSER_TOKEN_KIND_SETVARIABLE);
        self.tokenKindTab[@"pause"] = @(OUTLANDERPARSER_TOKEN_KIND_PAUSE);
        self.tokenKindTab[@":"] = @(OUTLANDERPARSER_TOKEN_KIND_COLON);

        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_SCRIPT] = @"script";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_ALIAS] = @"alias";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PUT] = @"put";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_POUND] = @"#";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_GOTO] = @"goto";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_EQUALS] = @"=";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_VAR] = @"var";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_HIGHLIGHT] = @"highlight";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_SETVARIABLE] = @"setvariable";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PAUSE] = @"pause";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_COLON] = @":";

        self.program_memo = [NSMutableDictionary dictionary];
        self.name_memo = [NSMutableDictionary dictionary];
        self.numberLiteral_memo = [NSMutableDictionary dictionary];
        self.stringLiteral_memo = [NSMutableDictionary dictionary];
        self.stmts_memo = [NSMutableDictionary dictionary];
        self.stmt_memo = [NSMutableDictionary dictionary];
        self.commands_memo = [NSMutableDictionary dictionary];
        self.commandExpr_memo = [NSMutableDictionary dictionary];
        self.setVar_memo = [NSMutableDictionary dictionary];
        self.putLiterals_memo = [NSMutableDictionary dictionary];
        self.putExpr_memo = [NSMutableDictionary dictionary];
        self.commandsStmt_memo = [NSMutableDictionary dictionary];
        self.putStmt_memo = [NSMutableDictionary dictionary];
        self.pauseStmt_memo = [NSMutableDictionary dictionary];
        self.labelStmt_memo = [NSMutableDictionary dictionary];
        self.gotoStmt_memo = [NSMutableDictionary dictionary];
        self.varStmt_memo = [NSMutableDictionary dictionary];
        self.nameExprPair_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)_clearMemo {
    [_program_memo removeAllObjects];
    [_name_memo removeAllObjects];
    [_numberLiteral_memo removeAllObjects];
    [_stringLiteral_memo removeAllObjects];
    [_stmts_memo removeAllObjects];
    [_stmt_memo removeAllObjects];
    [_commands_memo removeAllObjects];
    [_commandExpr_memo removeAllObjects];
    [_setVar_memo removeAllObjects];
    [_putLiterals_memo removeAllObjects];
    [_putExpr_memo removeAllObjects];
    [_commandsStmt_memo removeAllObjects];
    [_putStmt_memo removeAllObjects];
    [_pauseStmt_memo removeAllObjects];
    [_labelStmt_memo removeAllObjects];
    [_gotoStmt_memo removeAllObjects];
    [_varStmt_memo removeAllObjects];
    [_nameExprPair_memo removeAllObjects];
}

- (void)start {
    [self tryAndRecover:TOKEN_KIND_BUILTIN_EOF block:^{
        [self program_]; 
        [self matchEOF:YES]; 
    } completion:^{
        [self matchEOF:YES];
    }];
}

- (void)__program {
    
    [self fireDelegateSelector:@selector(parser:willMatchProgram:)];
        [self execute:(id)^{
    
        PKTokenizer *t = self.tokenizer;
        
        // setup comments
        t.commentState.reportsCommentTokens = YES;
        [t.commentState addSingleLineStartMarker:@"//"];
        [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];

    }];
    [self stmts_]; 

    [self fireDelegateSelector:@selector(parser:didMatchProgram:)];
}

- (void)program_ {
    [self parseRule:@selector(__program) withMemo:_program_memo];
}

- (void)__name {
    
    [self fireDelegateSelector:@selector(parser:willMatchName:)];
        [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchName:)];
}

- (void)name_ {
    [self parseRule:@selector(__name) withMemo:_name_memo];
}

- (void)__numberLiteral {
    
    [self fireDelegateSelector:@selector(parser:willMatchNumberLiteral:)];
        [self matchNumber:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchNumberLiteral:)];
}

- (void)numberLiteral_ {
    [self parseRule:@selector(__numberLiteral) withMemo:_numberLiteral_memo];
}

- (void)__stringLiteral {
    
    [self fireDelegateSelector:@selector(parser:willMatchStringLiteral:)];
        [self matchQuotedString:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchStringLiteral:)];
}

- (void)stringLiteral_ {
    [self parseRule:@selector(__stringLiteral) withMemo:_stringLiteral_memo];
}

- (void)__stmts {
    
    [self fireDelegateSelector:@selector(parser:willMatchStmts:)];
        while ([self speculate:^{ [self stmt_]; }]) {
        [self stmt_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchStmts:)];
}

- (void)stmts_ {
    [self parseRule:@selector(__stmts) withMemo:_stmts_memo];
}

- (void)__stmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchStmt:)];
        if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_SETVARIABLE, OUTLANDERPARSER_TOKEN_KIND_VAR, 0]) {
        [self varStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_POUND, 0]) {
        [self commandsStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PUT, 0]) {
        [self putStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PAUSE, 0]) {
        [self pauseStmt_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self labelStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_GOTO, 0]) {
        [self gotoStmt_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'stmt'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchStmt:)];
}

- (void)stmt_ {
    [self parseRule:@selector(__stmt) withMemo:_stmt_memo];
}

- (void)__commands {
    
    [self fireDelegateSelector:@selector(parser:willMatchCommands:)];
        if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_VAR, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_VAR discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_SCRIPT, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_SCRIPT discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_HIGHLIGHT, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_HIGHLIGHT discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_ALIAS, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_ALIAS discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'commands'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchCommands:)];
}

- (void)commands_ {
    [self parseRule:@selector(__commands) withMemo:_commands_memo];
}

- (void)__commandExpr {
    
    [self fireDelegateSelector:@selector(parser:willMatchCommandExpr:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_POUND discard:YES]; 
    [self commands_]; 
    while ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self name_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchCommandExpr:)];
}

- (void)commandExpr_ {
    [self parseRule:@selector(__commandExpr) withMemo:_commandExpr_memo];
}

- (void)__setVar {
    
    [self fireDelegateSelector:@selector(parser:willMatchSetVar:)];
        if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_VAR, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_VAR discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_SETVARIABLE, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_SETVARIABLE discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'setVar'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchSetVar:)];
}

- (void)setVar_ {
    [self parseRule:@selector(__setVar) withMemo:_setVar_memo];
}

- (void)__putLiterals {
    
    [self fireDelegateSelector:@selector(parser:willMatchPutLiterals:)];
        if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self name_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self stringLiteral_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self numberLiteral_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'putLiterals'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchPutLiterals:)];
}

- (void)putLiterals_ {
    [self parseRule:@selector(__putLiterals) withMemo:_putLiterals_memo];
}

- (void)__putExpr {
    
    [self fireDelegateSelector:@selector(parser:willMatchPutExpr:)];
        [self putLiterals_]; 
    while ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self putLiterals_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchPutExpr:)];
}

- (void)putExpr_ {
    [self parseRule:@selector(__putExpr) withMemo:_putExpr_memo];
}

- (void)__commandsStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchCommandsStmt:)];
        [self commandExpr_]; 

    [self fireDelegateSelector:@selector(parser:didMatchCommandsStmt:)];
}

- (void)commandsStmt_ {
    [self parseRule:@selector(__commandsStmt) withMemo:_commandsStmt_memo];
}

- (void)__putStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchPutStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_PUT discard:YES]; 
    [self putExpr_]; 

    [self fireDelegateSelector:@selector(parser:didMatchPutStmt:)];
}

- (void)putStmt_ {
    [self parseRule:@selector(__putStmt) withMemo:_putStmt_memo];
}

- (void)__pauseStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchPauseStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_PAUSE discard:YES]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self numberLiteral_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchPauseStmt:)];
}

- (void)pauseStmt_ {
    [self parseRule:@selector(__pauseStmt) withMemo:_pauseStmt_memo];
}

- (void)__labelStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchLabelStmt:)];
        [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_COLON block:^{ 
        [self name_]; 
        [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:YES]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:YES]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchLabelStmt:)];
}

- (void)labelStmt_ {
    [self parseRule:@selector(__labelStmt) withMemo:_labelStmt_memo];
}

- (void)__gotoStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchGotoStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_GOTO discard:YES]; 
    [self name_]; 

    [self fireDelegateSelector:@selector(parser:didMatchGotoStmt:)];
}

- (void)gotoStmt_ {
    [self parseRule:@selector(__gotoStmt) withMemo:_gotoStmt_memo];
}

- (void)__varStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchVarStmt:)];
        [self setVar_]; 
    [self nameExprPair_]; 

    [self fireDelegateSelector:@selector(parser:didMatchVarStmt:)];
}

- (void)varStmt_ {
    [self parseRule:@selector(__varStmt) withMemo:_varStmt_memo];
}

- (void)__nameExprPair {
    
    [self fireDelegateSelector:@selector(parser:willMatchNameExprPair:)];
        [self name_]; 
    if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_EQUALS, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_EQUALS discard:YES]; 
    }
    [self name_]; 

    [self fireDelegateSelector:@selector(parser:didMatchNameExprPair:)];
}

- (void)nameExprPair_ {
    [self parseRule:@selector(__nameExprPair) withMemo:_nameExprPair_memo];
}

@end