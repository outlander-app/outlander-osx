#import "OutlanderParser.h"
#import <PEGKit/PEGKit.h>


@interface OutlanderParser ()

@property (nonatomic, retain) NSMutableDictionary *program_memo;
@property (nonatomic, retain) NSMutableDictionary *name_memo;
@property (nonatomic, retain) NSMutableDictionary *refinement_memo;
@property (nonatomic, retain) NSMutableDictionary *numberLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *stringLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *stmts_memo;
@property (nonatomic, retain) NSMutableDictionary *stmt_memo;
@property (nonatomic, retain) NSMutableDictionary *exprStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *waitForStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *waitForReStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *waitStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *moveExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *moveStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *commands_memo;
@property (nonatomic, retain) NSMutableDictionary *commandsExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptAbort_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptPause_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptResume_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptCommands_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptCommandsExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *commandsStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *putLiterals_memo;
@property (nonatomic, retain) NSMutableDictionary *putExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *putStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *echoStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *pauseStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *labelStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *gotoStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *setVar_memo;
@property (nonatomic, retain) NSMutableDictionary *varStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *nameExprPair_memo;
@end

@implementation OutlanderParser { }

- (id)initWithDelegate:(id)d {
    self = [super initWithDelegate:d];
    if (self) {
        
        self.startRuleName = @"program";
        self.enableAutomaticErrorRecovery = YES;

        self.tokenKindTab[@"move"] = @(OUTLANDERPARSER_TOKEN_KIND_MOVE);
        self.tokenKindTab[@":"] = @(OUTLANDERPARSER_TOKEN_KIND_COLON);
        self.tokenKindTab[@"abort"] = @(OUTLANDERPARSER_TOKEN_KIND_ABORT);
        self.tokenKindTab[@";"] = @(OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON);
        self.tokenKindTab[@"."] = @(OUTLANDERPARSER_TOKEN_KIND_DOT);
        self.tokenKindTab[@"echo"] = @(OUTLANDERPARSER_TOKEN_KIND_ECHO);
        self.tokenKindTab[@"pause"] = @(OUTLANDERPARSER_TOKEN_KIND_PAUSE);
        self.tokenKindTab[@"="] = @(OUTLANDERPARSER_TOKEN_KIND_EQUALS);
        self.tokenKindTab[@"put"] = @(OUTLANDERPARSER_TOKEN_KIND_PUT);
        self.tokenKindTab[@"wait"] = @(OUTLANDERPARSER_TOKEN_KIND_WAITSTMT);
        self.tokenKindTab[@"#"] = @(OUTLANDERPARSER_TOKEN_KIND_POUND);
        self.tokenKindTab[@"alias"] = @(OUTLANDERPARSER_TOKEN_KIND_ALIAS);
        self.tokenKindTab[@"nextroom"] = @(OUTLANDERPARSER_TOKEN_KIND_NEXTROOM);
        self.tokenKindTab[@"$"] = @(OUTLANDERPARSER_TOKEN_KIND_DOLLAR);
        self.tokenKindTab[@"waitforre"] = @(OUTLANDERPARSER_TOKEN_KIND_WAITFORRE);
        self.tokenKindTab[@"waitfor"] = @(OUTLANDERPARSER_TOKEN_KIND_WAITFOR);
        self.tokenKindTab[@"resume"] = @(OUTLANDERPARSER_TOKEN_KIND_RESUME);
        self.tokenKindTab[@"%"] = @(OUTLANDERPARSER_TOKEN_KIND_PERCENT);
        self.tokenKindTab[@"script"] = @(OUTLANDERPARSER_TOKEN_KIND_SCRIPT);
        self.tokenKindTab[@"setvariable"] = @(OUTLANDERPARSER_TOKEN_KIND_SETVARIABLE);
        self.tokenKindTab[@"goto"] = @(OUTLANDERPARSER_TOKEN_KIND_GOTO);
        self.tokenKindTab[@"|"] = @(OUTLANDERPARSER_TOKEN_KIND_PIPE);
        self.tokenKindTab[@"highlight"] = @(OUTLANDERPARSER_TOKEN_KIND_HIGHLIGHT);
        self.tokenKindTab[@"var"] = @(OUTLANDERPARSER_TOKEN_KIND_VAR);

        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_MOVE] = @"move";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_COLON] = @":";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_ABORT] = @"abort";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON] = @";";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_ECHO] = @"echo";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PAUSE] = @"pause";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_EQUALS] = @"=";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PUT] = @"put";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_WAITSTMT] = @"wait";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_POUND] = @"#";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_ALIAS] = @"alias";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_NEXTROOM] = @"nextroom";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_DOLLAR] = @"$";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_WAITFORRE] = @"waitforre";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_WAITFOR] = @"waitfor";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_RESUME] = @"resume";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PERCENT] = @"%";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_SCRIPT] = @"script";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_SETVARIABLE] = @"setvariable";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_GOTO] = @"goto";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_PIPE] = @"|";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_HIGHLIGHT] = @"highlight";
        self.tokenKindNameTab[OUTLANDERPARSER_TOKEN_KIND_VAR] = @"var";

        self.program_memo = [NSMutableDictionary dictionary];
        self.name_memo = [NSMutableDictionary dictionary];
        self.refinement_memo = [NSMutableDictionary dictionary];
        self.numberLiteral_memo = [NSMutableDictionary dictionary];
        self.stringLiteral_memo = [NSMutableDictionary dictionary];
        self.stmts_memo = [NSMutableDictionary dictionary];
        self.stmt_memo = [NSMutableDictionary dictionary];
        self.exprStmt_memo = [NSMutableDictionary dictionary];
        self.waitForStmt_memo = [NSMutableDictionary dictionary];
        self.waitForReStmt_memo = [NSMutableDictionary dictionary];
        self.waitStmt_memo = [NSMutableDictionary dictionary];
        self.moveExpr_memo = [NSMutableDictionary dictionary];
        self.moveStmt_memo = [NSMutableDictionary dictionary];
        self.commands_memo = [NSMutableDictionary dictionary];
        self.commandsExpr_memo = [NSMutableDictionary dictionary];
        self.scriptAbort_memo = [NSMutableDictionary dictionary];
        self.scriptPause_memo = [NSMutableDictionary dictionary];
        self.scriptResume_memo = [NSMutableDictionary dictionary];
        self.scriptCommands_memo = [NSMutableDictionary dictionary];
        self.scriptCommandsExpr_memo = [NSMutableDictionary dictionary];
        self.commandsStmt_memo = [NSMutableDictionary dictionary];
        self.putLiterals_memo = [NSMutableDictionary dictionary];
        self.putExpr_memo = [NSMutableDictionary dictionary];
        self.putStmt_memo = [NSMutableDictionary dictionary];
        self.echoStmt_memo = [NSMutableDictionary dictionary];
        self.pauseStmt_memo = [NSMutableDictionary dictionary];
        self.labelStmt_memo = [NSMutableDictionary dictionary];
        self.gotoStmt_memo = [NSMutableDictionary dictionary];
        self.setVar_memo = [NSMutableDictionary dictionary];
        self.varStmt_memo = [NSMutableDictionary dictionary];
        self.nameExprPair_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)clearMemo {
    [_program_memo removeAllObjects];
    [_name_memo removeAllObjects];
    [_refinement_memo removeAllObjects];
    [_numberLiteral_memo removeAllObjects];
    [_stringLiteral_memo removeAllObjects];
    [_stmts_memo removeAllObjects];
    [_stmt_memo removeAllObjects];
    [_exprStmt_memo removeAllObjects];
    [_waitForStmt_memo removeAllObjects];
    [_waitForReStmt_memo removeAllObjects];
    [_waitStmt_memo removeAllObjects];
    [_moveExpr_memo removeAllObjects];
    [_moveStmt_memo removeAllObjects];
    [_commands_memo removeAllObjects];
    [_commandsExpr_memo removeAllObjects];
    [_scriptAbort_memo removeAllObjects];
    [_scriptPause_memo removeAllObjects];
    [_scriptResume_memo removeAllObjects];
    [_scriptCommands_memo removeAllObjects];
    [_scriptCommandsExpr_memo removeAllObjects];
    [_commandsStmt_memo removeAllObjects];
    [_putLiterals_memo removeAllObjects];
    [_putExpr_memo removeAllObjects];
    [_putStmt_memo removeAllObjects];
    [_echoStmt_memo removeAllObjects];
    [_pauseStmt_memo removeAllObjects];
    [_labelStmt_memo removeAllObjects];
    [_gotoStmt_memo removeAllObjects];
    [_setVar_memo removeAllObjects];
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

    [self execute:^{
    
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

    if ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_PERCENT discard:NO]; [self matchWord:NO]; }]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_PERCENT discard:NO]; 
        [self matchWord:NO]; 
    } else if ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_DOLLAR discard:NO]; [self matchWord:NO]; }]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_DOLLAR discard:NO]; 
        [self matchWord:NO]; 
    } else if ([self speculate:^{ [self matchWord:NO]; }]) {
        [self matchWord:NO]; 
    } else if ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_PERCENT discard:NO]; [self matchNumber:NO]; }]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_PERCENT discard:NO]; 
        [self matchNumber:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'name'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchName:)];
}

- (void)name_ {
    [self parseRule:@selector(__name) withMemo:_name_memo];
}

- (void)__refinement {
    
    [self fireDelegateSelector:@selector(parser:willMatchRefinement:)];

    if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_DOT, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_DOT discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PIPE, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_PIPE discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'refinement'."];
    }
    [self name_]; 

    [self fireDelegateSelector:@selector(parser:didMatchRefinement:)];
}

- (void)refinement_ {
    [self parseRule:@selector(__refinement) withMemo:_refinement_memo];
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

    [self stmt_]; 
    while ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:YES]; [self stmt_]; }]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_SEMI_COLON discard:YES]; 
        [self stmt_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchStmts:)];
}

- (void)stmts_ {
    [self parseRule:@selector(__stmts) withMemo:_stmts_memo];
}

- (void)__stmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchStmt:)];

    if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_POUND, 0]) {
        [self commandsStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_SETVARIABLE, OUTLANDERPARSER_TOKEN_KIND_VAR, 0]) {
        [self varStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PUT, 0]) {
        [self putStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_ECHO, 0]) {
        [self echoStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_PAUSE, 0]) {
        [self pauseStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_DOLLAR, OUTLANDERPARSER_TOKEN_KIND_PERCENT, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self labelStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_GOTO, 0]) {
        [self gotoStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_MOVE, OUTLANDERPARSER_TOKEN_KIND_NEXTROOM, 0]) {
        [self moveStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_WAITSTMT, 0]) {
        [self waitStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_WAITFOR, 0]) {
        [self waitForStmt_]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_WAITFORRE, 0]) {
        [self waitForReStmt_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'stmt'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchStmt:)];
}

- (void)stmt_ {
    [self parseRule:@selector(__stmt) withMemo:_stmt_memo];
}

- (void)__exprStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchExprStmt:)];

    if ([self speculate:^{ [self name_]; }]) {
        [self name_]; 
    }
    while ([self speculate:^{ [self refinement_]; }]) {
        [self refinement_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchExprStmt:)];
}

- (void)exprStmt_ {
    [self parseRule:@selector(__exprStmt) withMemo:_exprStmt_memo];
}

- (void)__waitForStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchWaitForStmt:)];

    [self match:OUTLANDERPARSER_TOKEN_KIND_WAITFOR discard:YES]; 
    [self putExpr_]; 

    [self fireDelegateSelector:@selector(parser:didMatchWaitForStmt:)];
}

- (void)waitForStmt_ {
    [self parseRule:@selector(__waitForStmt) withMemo:_waitForStmt_memo];
}

- (void)__waitForReStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchWaitForReStmt:)];

    [self match:OUTLANDERPARSER_TOKEN_KIND_WAITFORRE discard:YES]; 
    [self putExpr_]; 

    [self fireDelegateSelector:@selector(parser:didMatchWaitForReStmt:)];
}

- (void)waitForReStmt_ {
    [self parseRule:@selector(__waitForReStmt) withMemo:_waitForReStmt_memo];
}

- (void)__waitStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchWaitStmt:)];

    [self match:OUTLANDERPARSER_TOKEN_KIND_WAITSTMT discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchWaitStmt:)];
}

- (void)waitStmt_ {
    [self parseRule:@selector(__waitStmt) withMemo:_waitStmt_memo];
}

- (void)__moveExpr {
    
    [self fireDelegateSelector:@selector(parser:willMatchMoveExpr:)];

    if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_MOVE, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_MOVE discard:NO]; 
    } else if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_NEXTROOM, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_NEXTROOM discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'moveExpr'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchMoveExpr:)];
}

- (void)moveExpr_ {
    [self parseRule:@selector(__moveExpr) withMemo:_moveExpr_memo];
}

- (void)__moveStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchMoveStmt:)];

    [self moveExpr_]; 
    [self name_]; 

    [self fireDelegateSelector:@selector(parser:didMatchMoveStmt:)];
}

- (void)moveStmt_ {
    [self parseRule:@selector(__moveStmt) withMemo:_moveStmt_memo];
}

- (void)__commands {
    
    [self fireDelegateSelector:@selector(parser:willMatchCommands:)];

    if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_VAR, 0]) {
        [self match:OUTLANDERPARSER_TOKEN_KIND_VAR discard:NO]; 
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

- (void)__commandsExpr {
    
    [self fireDelegateSelector:@selector(parser:willMatchCommandsExpr:)];

    [self match:OUTLANDERPARSER_TOKEN_KIND_POUND discard:YES]; 
    [self commands_]; 
    [self putLiterals_]; 
    [self putLiterals_]; 

    [self fireDelegateSelector:@selector(parser:didMatchCommandsExpr:)];
}

- (void)commandsExpr_ {
    [self parseRule:@selector(__commandsExpr) withMemo:_commandsExpr_memo];
}

- (void)__scriptAbort {
    
    [self fireDelegateSelector:@selector(parser:willMatchScriptAbort:)];

    [self match:OUTLANDERPARSER_TOKEN_KIND_SCRIPT discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_ABORT block:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_ABORT discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_ABORT discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchScriptAbort:)];
}

- (void)scriptAbort_ {
    [self parseRule:@selector(__scriptAbort) withMemo:_scriptAbort_memo];
}

- (void)__scriptPause {
    
    [self fireDelegateSelector:@selector(parser:willMatchScriptPause:)];

    [self match:OUTLANDERPARSER_TOKEN_KIND_SCRIPT discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_PAUSE block:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_PAUSE discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_PAUSE discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchScriptPause:)];
}

- (void)scriptPause_ {
    [self parseRule:@selector(__scriptPause) withMemo:_scriptPause_memo];
}

- (void)__scriptResume {
    
    [self fireDelegateSelector:@selector(parser:willMatchScriptResume:)];

    [self match:OUTLANDERPARSER_TOKEN_KIND_SCRIPT discard:NO]; 
    [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_RESUME block:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_RESUME discard:NO]; 
    } completion:^{ 
        [self match:OUTLANDERPARSER_TOKEN_KIND_RESUME discard:NO]; 
    }];

    [self fireDelegateSelector:@selector(parser:didMatchScriptResume:)];
}

- (void)scriptResume_ {
    [self parseRule:@selector(__scriptResume) withMemo:_scriptResume_memo];
}

- (void)__scriptCommands {
    
    [self fireDelegateSelector:@selector(parser:willMatchScriptCommands:)];

    if ([self speculate:^{ [self scriptResume_]; }]) {
        [self scriptResume_]; 
    } else if ([self speculate:^{ [self scriptAbort_]; }]) {
        [self scriptAbort_]; 
    } else if ([self speculate:^{ [self scriptPause_]; }]) {
        [self scriptPause_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'scriptCommands'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchScriptCommands:)];
}

- (void)scriptCommands_ {
    [self parseRule:@selector(__scriptCommands) withMemo:_scriptCommands_memo];
}

- (void)__scriptCommandsExpr {
    
    [self fireDelegateSelector:@selector(parser:willMatchScriptCommandsExpr:)];

    [self match:OUTLANDERPARSER_TOKEN_KIND_POUND discard:YES]; 
    [self scriptCommands_]; 
    [self putLiterals_]; 

    [self fireDelegateSelector:@selector(parser:didMatchScriptCommandsExpr:)];
}

- (void)scriptCommandsExpr_ {
    [self parseRule:@selector(__scriptCommandsExpr) withMemo:_scriptCommandsExpr_memo];
}

- (void)__commandsStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchCommandsStmt:)];

    if ([self speculate:^{ [self scriptCommandsExpr_]; }]) {
        [self scriptCommandsExpr_]; 
    } else if ([self speculate:^{ [self commandsExpr_]; }]) {
        [self commandsExpr_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'commandsStmt'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchCommandsStmt:)];
}

- (void)commandsStmt_ {
    [self parseRule:@selector(__commandsStmt) withMemo:_commandsStmt_memo];
}

- (void)__putLiterals {
    
    [self fireDelegateSelector:@selector(parser:willMatchPutLiterals:)];

    if ([self predicts:OUTLANDERPARSER_TOKEN_KIND_DOLLAR, OUTLANDERPARSER_TOKEN_KIND_PERCENT, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self exprStmt_]; 
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

    while ([self speculate:^{ [self putLiterals_]; }]) {
        [self putLiterals_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchPutExpr:)];
}

- (void)putExpr_ {
    [self parseRule:@selector(__putExpr) withMemo:_putExpr_memo];
}

- (void)__putStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchPutStmt:)];

            if ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_PUT discard:YES]; [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_PUT block:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_PUT discard:NO]; } completion:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_PUT discard:NO]; }];[self putExpr_]; }]) {
            [self match:OUTLANDERPARSER_TOKEN_KIND_PUT discard:YES]; 
            [self tryAndRecover:OUTLANDERPARSER_TOKEN_KIND_PUT block:^{ 
                [self match:OUTLANDERPARSER_TOKEN_KIND_PUT discard:NO]; 
            } completion:^{ 
                [self match:OUTLANDERPARSER_TOKEN_KIND_PUT discard:NO]; 
            }];
                [self putExpr_]; 
            } else if ([self speculate:^{ [self match:OUTLANDERPARSER_TOKEN_KIND_PUT discard:YES]; [self putExpr_]; }]) {
                [self match:OUTLANDERPARSER_TOKEN_KIND_PUT discard:YES]; 
                [self putExpr_]; 
            } else {
                [self raise:@"No viable alternative found in rule 'putStmt'."];
            }

    [self fireDelegateSelector:@selector(parser:didMatchPutStmt:)];
}

- (void)putStmt_ {
    [self parseRule:@selector(__putStmt) withMemo:_putStmt_memo];
}

- (void)__echoStmt {
    
    [self fireDelegateSelector:@selector(parser:willMatchEchoStmt:)];

    [self match:OUTLANDERPARSER_TOKEN_KIND_ECHO discard:YES]; 
    while ([self speculate:^{ [self putLiterals_]; }]) {
        [self putLiterals_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchEchoStmt:)];
}

- (void)echoStmt_ {
    [self parseRule:@selector(__echoStmt) withMemo:_echoStmt_memo];
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