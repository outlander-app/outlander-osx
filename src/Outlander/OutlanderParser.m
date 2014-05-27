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
@property (nonatomic, retain) NSMutableDictionary *arrayLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *blocks_memo;
@property (nonatomic, retain) NSMutableDictionary *breakStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *caseClause_memo;
@property (nonatomic, retain) NSMutableDictionary *disruptiveStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *doStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *escapedChar_memo;
@property (nonatomic, retain) NSMutableDictionary *exponent_memo;
@property (nonatomic, retain) NSMutableDictionary *expr_memo;
@property (nonatomic, retain) NSMutableDictionary *exprStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *forStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *fraction_memo;
@property (nonatomic, retain) NSMutableDictionary *function_memo;
@property (nonatomic, retain) NSMutableDictionary *functionBody_memo;
@property (nonatomic, retain) NSMutableDictionary *functionLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *ifStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *infixOp_memo;
@property (nonatomic, retain) NSMutableDictionary *integer_memo;
@property (nonatomic, retain) NSMutableDictionary *invocation_memo;
@property (nonatomic, retain) NSMutableDictionary *literal_memo;
@property (nonatomic, retain) NSMutableDictionary *name_memo;
@property (nonatomic, retain) NSMutableDictionary *numberLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *objectLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *nameValPair_memo;
@property (nonatomic, retain) NSMutableDictionary *parameters_memo;
@property (nonatomic, retain) NSMutableDictionary *prefixOp_memo;
@property (nonatomic, retain) NSMutableDictionary *refinement_memo;
@property (nonatomic, retain) NSMutableDictionary *regexLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *regexBody_memo;
@property (nonatomic, retain) NSMutableDictionary *regexMods_memo;
@property (nonatomic, retain) NSMutableDictionary *returnStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *stmts_memo;
@property (nonatomic, retain) NSMutableDictionary *stmt_memo;
@property (nonatomic, retain) NSMutableDictionary *nonFunction_memo;
@property (nonatomic, retain) NSMutableDictionary *stringLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *switchStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *throwStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *tryStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *put_memo;
@property (nonatomic, retain) NSMutableDictionary *pause_memo;
@property (nonatomic, retain) NSMutableDictionary *goto_memo;
@property (nonatomic, retain) NSMutableDictionary *setVar_memo;
@property (nonatomic, retain) NSMutableDictionary *putLiterals_memo;
@property (nonatomic, retain) NSMutableDictionary *putExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *putStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *pauseStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *labelStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *gotoStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *varStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *nameExprPair_memo;
@property (nonatomic, retain) NSMutableDictionary *whileStmt_memo;
@end

@implementation OutlanderParser

- (id)initWithDelegate:(id)d {
    self = [super initWithDelegate:d];
    if (self) {
        self.startRuleName = @"program";
        self.enableAutomaticErrorRecovery = YES;

        self.tokenKindTab[@"{"] = @(OUTLANDERPARSER_TOKEN_KIND_OPEN_CURLY);
        self.tokenKindTab[@">="] = @(OUTLANDERPARSER_TOKEN_KIND_GE);
        self.tokenKindTab[@"&&"] = @(OUTLANDERPARSER_TOKEN_KIND_DOUBLE_AMPERSAND);
        self.tokenKindTab[@"for"] = @(OUTLANDERPARSER_TOKEN_KIND_FOR);
        self.tokenKindTab[@"break"] = @(OUTLANDERPARSER_TOKEN_KIND_BREAK);
        self.tokenKindTab[@"}"] = @(OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY);
        self.tokenKindTab[@"return"] = @(OUTLANDERPARSER_TOKEN_KIND_RETURN);
        self.tokenKindTab[@"goto"] = @(OUTLANDERPARSER_TOKEN_KIND_GOTO);
        self.tokenKindTab[@"+="] = @(OUTLANDERPARSER_TOKEN_KIND_PLUS_EQUALS);
        self.tokenKindTab[@"function"] = @(OUTLANDERPARSER_TOKEN_KIND_FUNCTION);
        self.tokenKindTab[@"if"] = @(OUTLANDERPARSER_TOKEN_KIND_IF);
        self.tokenKindTab[@"new"] = @(OUTLANDERPARSER_TOKEN_KIND_NEW);
        self.tokenKindTab[@"else"] = @(OUTLANDERPARSER_TOKEN_KIND_ELSE);
        self.tokenKindTab[@"!"] = @(OUTLANDERPARSER_TOKEN_KIND_BANG);
        self.tokenKindTab[@"finally"] = @(OUTLANDERPARSER_TOKEN_KIND_FINALLY);
        self.tokenKindTab[@":"] = @(OUTLANDERPARSER_TOKEN_KIND_COLON);
        self.tokenKindTab[@"catch"] = @(OUTLANDERPARSER_TOKEN_KIND_CATCH);
        self.tokenKindTab[@"pause"] = @(OUTLANDERPARSER_TOKEN_KIND_PAUSE);
        self.tokenKindTab[@";"] = @(OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON);
        self.tokenKindTab[@"do"] = @(OUTLANDERPARSER_TOKEN_KIND_DO);
        self.tokenKindTab[@"<"] = @(OUTLANDERPARSER_TOKEN_KIND_LT);
        self.tokenKindTab[@"-="] = @(OUTLANDERPARSER_TOKEN_KIND_MINUS_EQUALS);
        self.tokenKindTab[@"%"] = @(OUTLANDERPARSER_TOKEN_KIND_PERCENT);
        self.tokenKindTab[@"="] = @(OUTLANDERPARSER_TOKEN_KIND_EQUALS);
        self.tokenKindTab[@"throw"] = @(OUTLANDERPARSER_TOKEN_KIND_THROW);
        self.tokenKindTab[@"try"] = @(OUTLANDERPARSER_TOKEN_KIND_TRY);
        self.tokenKindTab[@">"] = @(OUTLANDERPARSER_TOKEN_KIND_GT);
        self.tokenKindTab[@"/,/"] = @(OUTLANDERPARSER_TOKEN_KIND_REGEXBODY);
        self.tokenKindTab[@"typeof"] = @(OUTLANDERPARSER_TOKEN_KIND_TYPEOF);
        self.tokenKindTab[@"("] = @(OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN);
        self.tokenKindTab[@"while"] = @(OUTLANDERPARSER_TOKEN_KIND_WHILE);
        self.tokenKindTab[@"var"] = @(OUTLANDERPARSER_TOKEN_KIND_VAR);
        self.tokenKindTab[@")"] = @(OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN);
        self.tokenKindTab[@"||"] = @(OUTLANDERPARSER_TOKEN_KIND_DOUBLE_PIPE);
        self.tokenKindTab[@"*"] = @(OUTLANDERPARSER_TOKEN_KIND_STAR);
        self.tokenKindTab[@"+"] = @(OUTLANDERPARSER_TOKEN_KIND_PLUS);
        self.tokenKindTab[@"["] = @(OUTLANDERPARSER_TOKEN_KIND_OPEN_BRACKET);
        self.tokenKindTab[@","] = @(OUTLANDERPARSER_TOKEN_KIND_COMMA);
        self.tokenKindTab[@"delete"] = @(OUTLANDERPARSER_TOKEN_KIND_DELETE);
        self.tokenKindTab[@"switch"] = @(OUTLANDERPARSER_TOKEN_KIND_SWITCH);
        self.tokenKindTab[@"-"] = @(OUTLANDERPARSER_TOKEN_KIND_MINUS);
        self.tokenKindTab[@"in"] = @(OUTLANDERPARSER_TOKEN_KIND_IN);
        self.tokenKindTab[@"]"] = @(OUTLANDERPARSER_TOKEN_KIND_CLOSE_BRACKET);
        self.tokenKindTab[@"."] = @(OUTLANDERPARSER_TOKEN_KIND_DOT);
        self.tokenKindTab[@"default"] = @(OUTLANDERPARSER_TOKEN_KIND_DEFAULT);
        self.tokenKindTab[@"setvariable"] = @(OUTLANDERPARSER_TOKEN_KIND_SETVARIABLE);
        self.tokenKindTab[@"/"] = @(OUTLANDERPARSER_TOKEN_KIND_FORWARD_SLASH);
        self.tokenKindTab[@"case"] = @(OUTLANDERPARSER_TOKEN_KIND_CASE);
        self.tokenKindTab[@"<="] = @(OUTLANDERPARSER_TOKEN_KIND_LE);
        self.tokenKindTab[@"put"] = @(OUTLANDERPARSER_TOKEN_KIND_PUT);

        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_OPEN_CURLY] = @"{";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_GE] = @">=";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_DOUBLE_AMPERSAND] = @"&&";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_FOR] = @"for";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_BREAK] = @"break";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY] = @"}";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_RETURN] = @"return";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_GOTO] = @"goto";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PLUS_EQUALS] = @"+=";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_FUNCTION] = @"function";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_IF] = @"if";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_NEW] = @"new";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_ELSE] = @"else";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_BANG] = @"!";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_FINALLY] = @"finally";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_COLON] = @":";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_CATCH] = @"catch";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PAUSE] = @"pause";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON] = @";";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_DO] = @"do";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_LT] = @"<";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_MINUS_EQUALS] = @"-=";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PERCENT] = @"%";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_EQUALS] = @"=";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_THROW] = @"throw";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_TRY] = @"try";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_GT] = @">";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_REGEXBODY] = @"/,/";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_TYPEOF] = @"typeof";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN] = @"(";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_WHILE] = @"while";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_VAR] = @"var";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN] = @")";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_DOUBLE_PIPE] = @"||";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_STAR] = @"*";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PLUS] = @"+";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_OPEN_BRACKET] = @"[";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_DELETE] = @"delete";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_SWITCH] = @"switch";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_MINUS] = @"-";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_IN] = @"in";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_CLOSE_BRACKET] = @"]";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_DEFAULT] = @"default";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_SETVARIABLE] = @"setvariable";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_FORWARD_SLASH] = @"/";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_CASE] = @"case";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_LE] = @"<=";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PUT] = @"put";

        self.program_memo = [NSMutableDictionary dictionary];
        self.arrayLiteral_memo = [NSMutableDictionary dictionary];
        self.blocks_memo = [NSMutableDictionary dictionary];
        self.breakStmt_memo = [NSMutableDictionary dictionary];
        self.caseClause_memo = [NSMutableDictionary dictionary];
        self.disruptiveStmt_memo = [NSMutableDictionary dictionary];
        self.doStmt_memo = [NSMutableDictionary dictionary];
        self.escapedChar_memo = [NSMutableDictionary dictionary];
        self.exponent_memo = [NSMutableDictionary dictionary];
        self.expr_memo = [NSMutableDictionary dictionary];
        self.exprStmt_memo = [NSMutableDictionary dictionary];
        self.forStmt_memo = [NSMutableDictionary dictionary];
        self.fraction_memo = [NSMutableDictionary dictionary];
        self.function_memo = [NSMutableDictionary dictionary];
        self.functionBody_memo = [NSMutableDictionary dictionary];
        self.functionLiteral_memo = [NSMutableDictionary dictionary];
        self.ifStmt_memo = [NSMutableDictionary dictionary];
        self.infixOp_memo = [NSMutableDictionary dictionary];
        self.integer_memo = [NSMutableDictionary dictionary];
        self.invocation_memo = [NSMutableDictionary dictionary];
        self.literal_memo = [NSMutableDictionary dictionary];
        self.name_memo = [NSMutableDictionary dictionary];
        self.numberLiteral_memo = [NSMutableDictionary dictionary];
        self.objectLiteral_memo = [NSMutableDictionary dictionary];
        self.nameValPair_memo = [NSMutableDictionary dictionary];
        self.parameters_memo = [NSMutableDictionary dictionary];
        self.prefixOp_memo = [NSMutableDictionary dictionary];
        self.refinement_memo = [NSMutableDictionary dictionary];
        self.regexLiteral_memo = [NSMutableDictionary dictionary];
        self.regexBody_memo = [NSMutableDictionary dictionary];
        self.regexMods_memo = [NSMutableDictionary dictionary];
        self.returnStmt_memo = [NSMutableDictionary dictionary];
        self.stmts_memo = [NSMutableDictionary dictionary];
        self.stmt_memo = [NSMutableDictionary dictionary];
        self.nonFunction_memo = [NSMutableDictionary dictionary];
        self.stringLiteral_memo = [NSMutableDictionary dictionary];
        self.switchStmt_memo = [NSMutableDictionary dictionary];
        self.throwStmt_memo = [NSMutableDictionary dictionary];
        self.tryStmt_memo = [NSMutableDictionary dictionary];
        self.put_memo = [NSMutableDictionary dictionary];
        self.pause_memo = [NSMutableDictionary dictionary];
        self.goto_memo = [NSMutableDictionary dictionary];
        self.setVar_memo = [NSMutableDictionary dictionary];
        self.putLiterals_memo = [NSMutableDictionary dictionary];
        self.putExpr_memo = [NSMutableDictionary dictionary];
        self.putStmt_memo = [NSMutableDictionary dictionary];
        self.pauseStmt_memo = [NSMutableDictionary dictionary];
        self.labelStmt_memo = [NSMutableDictionary dictionary];
        self.gotoStmt_memo = [NSMutableDictionary dictionary];
        self.varStmt_memo = [NSMutableDictionary dictionary];
        self.nameExprPair_memo = [NSMutableDictionary dictionary];
        self.whileStmt_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)_clearMemo {
    [_program_memo removeAllObjects];
    [_arrayLiteral_memo removeAllObjects];
    [_blocks_memo removeAllObjects];
    [_breakStmt_memo removeAllObjects];
    [_caseClause_memo removeAllObjects];
    [_disruptiveStmt_memo removeAllObjects];
    [_doStmt_memo removeAllObjects];
    [_escapedChar_memo removeAllObjects];
    [_exponent_memo removeAllObjects];
    [_expr_memo removeAllObjects];
    [_exprStmt_memo removeAllObjects];
    [_forStmt_memo removeAllObjects];
    [_fraction_memo removeAllObjects];
    [_function_memo removeAllObjects];
    [_functionBody_memo removeAllObjects];
    [_functionLiteral_memo removeAllObjects];
    [_ifStmt_memo removeAllObjects];
    [_infixOp_memo removeAllObjects];
    [_integer_memo removeAllObjects];
    [_invocation_memo removeAllObjects];
    [_literal_memo removeAllObjects];
    [_name_memo removeAllObjects];
    [_numberLiteral_memo removeAllObjects];
    [_objectLiteral_memo removeAllObjects];
    [_nameValPair_memo removeAllObjects];
    [_parameters_memo removeAllObjects];
    [_prefixOp_memo removeAllObjects];
    [_refinement_memo removeAllObjects];
    [_regexLiteral_memo removeAllObjects];
    [_regexBody_memo removeAllObjects];
    [_regexMods_memo removeAllObjects];
    [_returnStmt_memo removeAllObjects];
    [_stmts_memo removeAllObjects];
    [_stmt_memo removeAllObjects];
    [_nonFunction_memo removeAllObjects];
    [_stringLiteral_memo removeAllObjects];
    [_switchStmt_memo removeAllObjects];
    [_throwStmt_memo removeAllObjects];
    [_tryStmt_memo removeAllObjects];
    [_put_memo removeAllObjects];
    [_pause_memo removeAllObjects];
    [_goto_memo removeAllObjects];
    [_setVar_memo removeAllObjects];
    [_putLiterals_memo removeAllObjects];
    [_putExpr_memo removeAllObjects];
    [_putStmt_memo removeAllObjects];
    [_pauseStmt_memo removeAllObjects];
    [_labelStmt_memo removeAllObjects];
    [_gotoStmt_memo removeAllObjects];
    [_varStmt_memo removeAllObjects];
    [_nameExprPair_memo removeAllObjects];
    [_whileStmt_memo removeAllObjects];
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
        
        // whitespace
/*      self.silentlyConsumesWhitespace = YES;
        t.whitespaceState.reportsWhitespaceTokens = YES;
        self.assembly.preservesWhitespaceTokens = YES;
*/
        [t.symbolState add:@"||"];
        [t.symbolState add:@"&&"];
        [t.symbolState add:@"!="];
        [t.symbolState add:@"=="];
        [t.symbolState add:@"<="];
        [t.symbolState add:@">="];
        [t.symbolState add:@"++"];
        [t.symbolState add:@"--"];
        [t.symbolState add:@"+="];
        [t.symbolState add:@"-="];
        [t.symbolState add:@"*="];
        [t.symbolState add:@"/="];
        [t.symbolState add:@"%="];

        // setup comments
        t.commentState.reportsCommentTokens = YES;
        [t setTokenizerState:t.commentState from:'/' to:'/'];
        [t.commentState addSingleLineStartMarker:@"//"];
        [t.commentState addSingleLineStartMarker:@"#"];
        [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
        
        // comment state should fallback to delimit state to match regex delimited strings
        t.commentState.fallbackState = t.delimitState;
        
        // regex delimited strings
        NSCharacterSet *cs = [[NSCharacterSet newlineCharacterSet] invertedSet];
        [t.delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];

    }];
    [self stmts_]; 

    [self fireDelegateSelector:@selector(parser:didMatchProgram:)];
}

- (void)program_ {
    [self parseRule:@selector(__program) withMemo:_program_memo];
}

- (void)__arrayLiteral {
    
    [self fireDelegateSelector:@selector(parser:willMatchArrayLiteral:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_BRACKET discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_BRACKET block:^{ 
        if ([self speculate:^{ [self expr_]; while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self expr_]; }]) {[self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self expr_]; }}]) {
            [self expr_]; 
            while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self expr_]; }]) {
                [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; 
                [self expr_]; 
            }
        }
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_BRACKET discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_BRACKET discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchArrayLiteral:)];
}

- (void)arrayLiteral_ {
    [self parseRule:@selector(__arrayLiteral) withMemo:_arrayLiteral_memo];
}

- (void)__blocks {
    
    [self fireDelegateSelector:@selector(parser:willMatchBlocks:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_CURLY discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY block:^{ 
        if ([self speculate:^{ [self stmts_]; }]) {
            [self stmts_]; 
        }
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchBlocks:)];
}

- (void)blocks_ {
    [self parseRule:@selector(__blocks) withMemo:_blocks_memo];
}

- (void)__breakStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchBreakStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_BREAK discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON block:^{ 
        if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self name_]; 
        }
        [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchBreakStmt:)];
}

- (void)breakStmt_ {
    [self parseRule:@selector(__breakStmt) withMemo:_breakStmt_memo];
}

- (void)__caseClause {
    
    [self fireDelegateSelector:@selector(parser:willMatchCaseClause:)];
        do {
        [self match:OUTLANDERPARSER_TOKEN_KIND_CASE discard:NO]; 
        [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_COLON block:^{ 
            [self expr_]; 
            [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:NO]; 
        } completion:^{ 
            [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:NO]; 
        }];
    } while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_CASE discard:NO]; [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_COLON block:^{ [self expr_]; [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:NO]; } completion:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:NO]; }];}]);
    [self stmts_]; 

    [self fireDelegateSelector:@selector(parser:didMatchCaseClause:)];
}

- (void)caseClause_ {
    [self parseRule:@selector(__caseClause) withMemo:_caseClause_memo];
}

- (void)__disruptiveStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchDisruptiveStmt:)];
        if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_BREAK, 0]) {
        [self breakStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_RETURN, 0]) {
        [self returnStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_THROW, 0]) {
        [self throwStmt_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'disruptiveStmt'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchDisruptiveStmt:)];
}

- (void)disruptiveStmt_ {
    [self parseRule:@selector(__disruptiveStmt) withMemo:_disruptiveStmt_memo];
}

- (void)__doStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchDoStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_DO discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_WHILE block:^{ 
        [self blocks_]; 
        [self match:OUTLANDERPARSER_TOKEN_KIND_WHILE discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_WHILE discard:NO]; 
    }];
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN block:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    }];
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN block:^{ 
        [self expr_]; 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    }];
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON block:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchDoStmt:)];
}

- (void)doStmt_ {
    [self parseRule:@selector(__doStmt) withMemo:_doStmt_memo];
}

- (void)__escapedChar {
    
    [self fireDelegateSelector:@selector(parser:willMatchEscapedChar:)];
        [self matchSymbol:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchEscapedChar:)];
}

- (void)escapedChar_ {
    [self parseRule:@selector(__escapedChar) withMemo:_escapedChar_memo];
}

- (void)__exponent {
    
    [self fireDelegateSelector:@selector(parser:willMatchExponent:)];
        [self matchNumber:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchExponent:)];
}

- (void)exponent_ {
    [self parseRule:@selector(__exponent) withMemo:_exponent_memo];
}

- (void)__expr {
    
    [self fireDelegateSelector:@selector(parser:willMatchExpr:)];
        if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_FUNCTION, OUTLANDERPARSER_TOKEN_KIND_OPEN_BRACKET, OUTLANDERPARSER_TOKEN_KIND_REGEXBODY, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self literal_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self name_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
        [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN block:^{ 
            [self expr_]; 
            [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
        } completion:^{ 
            [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
        }];
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_BANG, OUTLANDERPARSER_TOKEN_KIND_TYPEOF, 0]) {
        [self prefixOp_]; 
        [self expr_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_NEW, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_NEW discard:NO]; 
        [self expr_]; 
        [self invocation_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_DELETE, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_DELETE discard:NO]; 
        [self expr_]; 
        [self refinement_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'expr'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchExpr:)];
}

- (void)expr_ {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

- (void)__exprStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchExprStmt:)];
        if ([self speculate:^{ do {[self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_EQUALS block:^{ [self name_]; while ([self speculate:^{ [self refinement_]; }]) {[self refinement_]; }[self match:OUTLANDERPARSER_TOKEN_KIND_EQUALS discard:NO]; } completion:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_EQUALS discard:NO]; }];} while ([self speculate:^{ [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_EQUALS block:^{ [self name_]; while ([self speculate:^{ [self refinement_]; }]) {[self refinement_]; }[self match:OUTLANDERPARSER_TOKEN_KIND_EQUALS discard:NO]; } completion:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_EQUALS discard:NO]; }];}]);[self expr_]; }]) {
        do {
            [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_EQUALS block:^{ 
                [self name_]; 
                while ([self speculate:^{ [self refinement_]; }]) {
                    [self refinement_]; 
                }
                [self match:OUTLANDERPARSER_TOKEN_KIND_EQUALS discard:NO]; 
            } completion:^{ 
                [self match:OUTLANDERPARSER_TOKEN_KIND_EQUALS discard:NO]; 
            }];
        } while ([self speculate:^{ [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_EQUALS block:^{ [self name_]; while ([self speculate:^{ [self refinement_]; }]) {[self refinement_]; }[self match:OUTLANDERPARSER_TOKEN_KIND_EQUALS discard:NO]; } completion:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_EQUALS discard:NO]; }];}]);
        [self expr_]; 
    } else if ([self speculate:^{ [self name_]; while ([self speculate:^{ [self refinement_]; }]) {[self refinement_]; }if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PLUS_EQUALS, 0]) {[self match:OUTLANDERPARSER_TOKEN_KIND_PLUS_EQUALS discard:NO]; } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_MINUS_EQUALS, 0]) {[self match:OUTLANDERPARSER_TOKEN_KIND_MINUS_EQUALS discard:NO]; } else {[self raise:@"No viable alternative found in rule 'exprStmt'."];}[self expr_]; }]) {
        [self name_]; 
        while ([self speculate:^{ [self refinement_]; }]) {
            [self refinement_]; 
        }
        if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PLUS_EQUALS, 0]) {
            [self match:OUTLANDERPARSER_TOKEN_KIND_PLUS_EQUALS discard:NO]; 
        } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_MINUS_EQUALS, 0]) {
            [self match:OUTLANDERPARSER_TOKEN_KIND_MINUS_EQUALS discard:NO]; 
        } else {
            [self raise:@"No viable alternative found in rule 'exprStmt'."];
        }
        [self expr_]; 
    } else if ([self speculate:^{ [self name_]; while ([self speculate:^{ [self refinement_]; }]) {[self refinement_]; }do {[self invocation_]; } while ([self speculate:^{ [self invocation_]; }]);}]) {
        [self name_]; 
        while ([self speculate:^{ [self refinement_]; }]) {
            [self refinement_]; 
        }
        do {
            [self invocation_]; 
        } while ([self speculate:^{ [self invocation_]; }]);
    } else if ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_DELETE discard:NO]; [self expr_]; [self refinement_]; }]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_DELETE discard:NO]; 
        [self expr_]; 
        [self refinement_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'exprStmt'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchExprStmt:)];
}

- (void)exprStmt_ {
    [self parseRule:@selector(__exprStmt) withMemo:_exprStmt_memo];
}

- (void)__forStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchForStmt:)];
        if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_FOR, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_FOR discard:NO]; 
        [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN block:^{ 
            [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
        } completion:^{ 
            [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
        }];
            [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON block:^{ 
                if ([self speculate:^{ [self exprStmt_]; }]) {
                    [self exprStmt_]; 
                }
                [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
            } completion:^{ 
                [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
            }];
            [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON block:^{ 
                if ([self speculate:^{ [self expr_]; }]) {
                    [self expr_]; 
                }
                [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
            } completion:^{ 
                [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
            }];
                if ([self speculate:^{ [self exprStmt_]; }]) {
                    [self exprStmt_]; 
                }
            } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
                    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN block:^{ 
                    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_IN block:^{ 
                        [self name_]; 
                        [self match:OUTLANDERPARSER_TOKEN_KIND_IN discard:NO]; 
                    } completion:^{ 
                        [self match:OUTLANDERPARSER_TOKEN_KIND_IN discard:NO]; 
                    }];
                        [self expr_]; 
                        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
                    } completion:^{ 
                        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
                    }];
                        [self blocks_]; 
                    } else {
                        [self raise:@"No viable alternative found in rule 'forStmt'."];
                    }

    [self fireDelegateSelector:@selector(parser:didMatchForStmt:)];
}

- (void)forStmt_ {
    [self parseRule:@selector(__forStmt) withMemo:_forStmt_memo];
}

- (void)__fraction {
    
    [self fireDelegateSelector:@selector(parser:willMatchFraction:)];
        [self matchNumber:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchFraction:)];
}

- (void)fraction_ {
    [self parseRule:@selector(__fraction) withMemo:_fraction_memo];
}

- (void)__function {
    
    [self fireDelegateSelector:@selector(parser:willMatchFunction:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_FUNCTION discard:NO]; 
    [self name_]; 
    [self parameters_]; 
    [self functionBody_]; 

    [self fireDelegateSelector:@selector(parser:didMatchFunction:)];
}

- (void)function_ {
    [self parseRule:@selector(__function) withMemo:_function_memo];
}

- (void)__functionBody {
    
    [self fireDelegateSelector:@selector(parser:willMatchFunctionBody:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_CURLY discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY block:^{ 
        [self stmts_]; 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchFunctionBody:)];
}

- (void)functionBody_ {
    [self parseRule:@selector(__functionBody) withMemo:_functionBody_memo];
}

- (void)__functionLiteral {
    
    [self fireDelegateSelector:@selector(parser:willMatchFunctionLiteral:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_FUNCTION discard:NO]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self name_]; 
    }
    [self parameters_]; 
    [self functionBody_]; 

    [self fireDelegateSelector:@selector(parser:didMatchFunctionLiteral:)];
}

- (void)functionLiteral_ {
    [self parseRule:@selector(__functionLiteral) withMemo:_functionLiteral_memo];
}

- (void)__ifStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchIfStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_IF discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN block:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    }];
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN block:^{ 
        [self expr_]; 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    }];
        [self blocks_]; 
        if ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_ELSE discard:NO]; if ([self speculate:^{ [self ifStmt_]; }]) {[self ifStmt_]; }[self blocks_]; }]) {
            [self match:OUTLANDERPARSER_TOKEN_KIND_ELSE discard:NO]; 
            if ([self speculate:^{ [self ifStmt_]; }]) {
                [self ifStmt_]; 
            }
            [self blocks_]; 
        }

    [self fireDelegateSelector:@selector(parser:didMatchIfStmt:)];
}

- (void)ifStmt_ {
    [self parseRule:@selector(__ifStmt) withMemo:_ifStmt_memo];
}

- (void)__infixOp {
    
    [self fireDelegateSelector:@selector(parser:willMatchInfixOp:)];
        if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_STAR, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_STAR discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_FORWARD_SLASH, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_FORWARD_SLASH discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PERCENT, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_PERCENT discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PLUS, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_PLUS discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_MINUS, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_MINUS discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_GE, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_GE discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_LE, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_LE discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_GT, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_GT discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_LT, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_LT discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_DOUBLE_PIPE, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_DOUBLE_PIPE discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_DOUBLE_AMPERSAND, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_DOUBLE_AMPERSAND discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'infixOp'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchInfixOp:)];
}

- (void)infixOp_ {
    [self parseRule:@selector(__infixOp) withMemo:_infixOp_memo];
}

- (void)__integer {
    
    [self fireDelegateSelector:@selector(parser:willMatchInteger:)];
        [self matchNumber:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchInteger:)];
}

- (void)integer_ {
    [self parseRule:@selector(__integer) withMemo:_integer_memo];
}

- (void)__invocation {
    
    [self fireDelegateSelector:@selector(parser:willMatchInvocation:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN block:^{ 
        if ([self speculate:^{ [self expr_]; while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self expr_]; }]) {[self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self expr_]; }}]) {
            [self expr_]; 
            while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self expr_]; }]) {
                [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; 
                [self expr_]; 
            }
        }
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchInvocation:)];
}

- (void)invocation_ {
    [self parseRule:@selector(__invocation) withMemo:_invocation_memo];
}

- (void)__literal {
    
    [self fireDelegateSelector:@selector(parser:willMatchLiteral:)];
        if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self numberLiteral_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self stringLiteral_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self arrayLiteral_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_FUNCTION, 0]) {
        [self functionLiteral_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_REGEXBODY, 0]) {
        [self regexLiteral_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'literal'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchLiteral:)];
}

- (void)literal_ {
    [self parseRule:@selector(__literal) withMemo:_literal_memo];
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

- (void)__objectLiteral {
    
    [self fireDelegateSelector:@selector(parser:willMatchObjectLiteral:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_CURLY discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY block:^{ 
        if ([self speculate:^{ [self nameValPair_]; while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self nameValPair_]; }]) {[self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self nameValPair_]; }}]) {
            [self nameValPair_]; 
            while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self nameValPair_]; }]) {
                [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; 
                [self nameValPair_]; 
            }
        }
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchObjectLiteral:)];
}

- (void)objectLiteral_ {
    [self parseRule:@selector(__objectLiteral) withMemo:_objectLiteral_memo];
}

- (void)__nameValPair {
    
    [self fireDelegateSelector:@selector(parser:willMatchNameValPair:)];
        [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_COLON block:^{ 
        if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self name_]; 
        } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
            [self stringLiteral_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'nameValPair'."];
        }
        [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:NO]; 
    }];
        [self expr_]; 

    [self fireDelegateSelector:@selector(parser:didMatchNameValPair:)];
}

- (void)nameValPair_ {
    [self parseRule:@selector(__nameValPair) withMemo:_nameValPair_memo];
}

- (void)__parameters {
    
    [self fireDelegateSelector:@selector(parser:willMatchParameters:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN block:^{ 
        if ([self speculate:^{ [self name_]; while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self name_]; }]) {[self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self name_]; }}]) {
            [self name_]; 
            while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; [self name_]; }]) {
                [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:NO]; 
                [self name_]; 
            }
        }
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchParameters:)];
}

- (void)parameters_ {
    [self parseRule:@selector(__parameters) withMemo:_parameters_memo];
}

- (void)__prefixOp {
    
    [self fireDelegateSelector:@selector(parser:willMatchPrefixOp:)];
        if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_TYPEOF, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_TYPEOF discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_BANG, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_BANG discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'prefixOp'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchPrefixOp:)];
}

- (void)prefixOp_ {
    [self parseRule:@selector(__prefixOp) withMemo:_prefixOp_memo];
}

- (void)__refinement {
    
    [self fireDelegateSelector:@selector(parser:willMatchRefinement:)];
        if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_DOT, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_DOT discard:NO]; 
        [self name_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_BRACKET discard:NO]; 
        [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_BRACKET block:^{ 
            [self expr_]; 
            [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_BRACKET discard:NO]; 
        } completion:^{ 
            [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_BRACKET discard:NO]; 
        }];
    } else {
        [self raise:@"No viable alternative found in rule 'refinement'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchRefinement:)];
}

- (void)refinement_ {
    [self parseRule:@selector(__refinement) withMemo:_refinement_memo];
}

- (void)__regexLiteral {
    
    [self fireDelegateSelector:@selector(parser:willMatchRegexLiteral:)];
        [self regexBody_]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self regexMods_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchRegexLiteral:)];
}

- (void)regexLiteral_ {
    [self parseRule:@selector(__regexLiteral) withMemo:_regexLiteral_memo];
}

- (void)__regexBody {
    
    [self fireDelegateSelector:@selector(parser:willMatchRegexBody:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_REGEXBODY discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchRegexBody:)];
}

- (void)regexBody_ {
    [self parseRule:@selector(__regexBody) withMemo:_regexBody_memo];
}

- (void)__regexMods {
    
    [self fireDelegateSelector:@selector(parser:willMatchRegexMods:)];
        [self testAndThrow:(id)^{ return MATCHES_IGNORE_CASE(@"[imxs]+", LS(1)); }]; 
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchRegexMods:)];
}

- (void)regexMods_ {
    [self parseRule:@selector(__regexMods) withMemo:_regexMods_memo];
}

- (void)__returnStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchReturnStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_RETURN discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON block:^{ 
        if ([self speculate:^{ [self expr_]; }]) {
            [self expr_]; 
        }
        [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchReturnStmt:)];
}

- (void)returnStmt_ {
    [self parseRule:@selector(__returnStmt) withMemo:_returnStmt_memo];
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
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PUT, 0]) {
        [self putStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PAUSE, 0]) {
        [self pauseStmt_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self labelStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_GOTO, 0]) {
        [self gotoStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_FUNCTION, 0]) {
        [self function_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_IF, 0]) {
        [self nonFunction_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'stmt'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchStmt:)];
}

- (void)stmt_ {
    [self parseRule:@selector(__stmt) withMemo:_stmt_memo];
}

- (void)__nonFunction {
    
    [self fireDelegateSelector:@selector(parser:willMatchNonFunction:)];
        [self ifStmt_]; 

    [self fireDelegateSelector:@selector(parser:didMatchNonFunction:)];
}

- (void)nonFunction_ {
    [self parseRule:@selector(__nonFunction) withMemo:_nonFunction_memo];
}

- (void)__stringLiteral {
    
    [self fireDelegateSelector:@selector(parser:willMatchStringLiteral:)];
        [self matchQuotedString:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchStringLiteral:)];
}

- (void)stringLiteral_ {
    [self parseRule:@selector(__stringLiteral) withMemo:_stringLiteral_memo];
}

- (void)__switchStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchSwitchStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_SWITCH discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN block:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    }];
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN block:^{ 
        [self expr_]; 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    }];
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_OPEN_CURLY block:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_CURLY discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_CURLY discard:NO]; 
    }];
            [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY block:^{ 
        do {
            [self caseClause_]; 
            if ([self speculate:^{ [self disruptiveStmt_]; }]) {
                [self disruptiveStmt_]; 
            }
        } while ([self speculate:^{ [self caseClause_]; if ([self speculate:^{ [self disruptiveStmt_]; }]) {[self disruptiveStmt_]; }}]);
                if ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_DEFAULT discard:NO]; [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_COLON block:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:NO]; } completion:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:NO]; }];[self stmts_]; }]) {
                [self match:OUTLANDERPARSER_TOKEN_KIND_DEFAULT discard:NO]; 
                [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_COLON block:^{ 
                    [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:NO]; 
                } completion:^{ 
                    [self match:OUTLANDERPARSER_TOKEN_KIND_COLON discard:NO]; 
                }];
                    [self stmts_]; 
                }
                [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY discard:NO]; 
            } completion:^{ 
                [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_CURLY discard:NO]; 
            }];

    [self fireDelegateSelector:@selector(parser:didMatchSwitchStmt:)];
}

- (void)switchStmt_ {
    [self parseRule:@selector(__switchStmt) withMemo:_switchStmt_memo];
}

- (void)__throwStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchThrowStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_THROW discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON block:^{ 
        [self expr_]; 
        [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchThrowStmt:)];
}

- (void)throwStmt_ {
    [self parseRule:@selector(__throwStmt) withMemo:_throwStmt_memo];
}

- (void)__tryStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchTryStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_TRY discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CATCH block:^{ 
        [self blocks_]; 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CATCH discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CATCH discard:NO]; 
    }];
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN block:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    }];
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN block:^{ 
        [self name_]; 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    }];
        [self blocks_]; 
        if ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_FINALLY discard:NO]; [self blocks_]; }]) {
            [self match:OUTLANDERPARSER_TOKEN_KIND_FINALLY discard:NO]; 
            [self blocks_]; 
        }

    [self fireDelegateSelector:@selector(parser:didMatchTryStmt:)];
}

- (void)tryStmt_ {
    [self parseRule:@selector(__tryStmt) withMemo:_tryStmt_memo];
}

- (void)__put {
    
    [self fireDelegateSelector:@selector(parser:willMatchPut:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_PUT discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchPut:)];
}

- (void)put_ {
    [self parseRule:@selector(__put) withMemo:_put_memo];
}

- (void)__pause {
    
    [self fireDelegateSelector:@selector(parser:willMatchPause:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_PAUSE discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchPause:)];
}

- (void)pause_ {
    [self parseRule:@selector(__pause) withMemo:_pause_memo];
}

- (void)__goto {
    
    [self fireDelegateSelector:@selector(parser:willMatchGoto:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_GOTO discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchGoto:)];
}

- (void)goto_ {
    [self parseRule:@selector(__goto) withMemo:_goto_memo];
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
        while ([self speculate:^{ [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON block:^{ [self setVar_]; [self nameExprPair_]; while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:YES]; [self nameExprPair_]; }]) {[self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:YES]; [self nameExprPair_]; }[self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; } completion:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; }];}]) {
        [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON block:^{ 
            [self setVar_]; 
            [self nameExprPair_]; 
            while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:YES]; [self nameExprPair_]; }]) {
                [self match:OUTLANDERPARSER_TOKEN_KIND_COMMA discard:YES]; 
                [self nameExprPair_]; 
            }
            [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
        } completion:^{ 
            [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:NO]; 
        }];
    }

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
    [self expr_]; 

    [self fireDelegateSelector:@selector(parser:didMatchNameExprPair:)];
}

- (void)nameExprPair_ {
    [self parseRule:@selector(__nameExprPair) withMemo:_nameExprPair_memo];
}

- (void)__whileStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchWhileStmt:)];
        [self match:OUTLANDERPARSER_TOKEN_KIND_WHILE discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN block:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    }];
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN block:^{ 
        [self expr_]; 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    }];
        [self blocks_]; 

    [self fireDelegateSelector:@selector(parser:didMatchWhileStmt:)];
}

- (void)whileStmt_ {
    [self parseRule:@selector(__whileStmt) withMemo:_whileStmt_memo];
}

@end