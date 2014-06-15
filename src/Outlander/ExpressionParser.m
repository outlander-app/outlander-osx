#import "ExpressionParser.h"
#import <PEGKit/PEGKit.h>


@interface ExpressionParser ()

@property (nonatomic, retain) NSMutableDictionary *program_memo;
@property (nonatomic, retain) NSMutableDictionary *stmts_memo;
@property (nonatomic, retain) NSMutableDictionary *stmt_memo;
@property (nonatomic, retain) NSMutableDictionary *echoStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *exitStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *debuglevelStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *gosubStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *returnStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *gotoStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *matchStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *matchreStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *matchWaitStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *moveStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *nextRoom_memo;
@property (nonatomic, retain) NSMutableDictionary *pause_memo;
@property (nonatomic, retain) NSMutableDictionary *putCmds_memo;
@property (nonatomic, retain) NSMutableDictionary *putStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptAbort_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptPause_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptResume_memo;
@property (nonatomic, retain) NSMutableDictionary *commands_memo;
@property (nonatomic, retain) NSMutableDictionary *commandsExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *waitForStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *label_memo;
@property (nonatomic, retain) NSMutableDictionary *assignmentPrefix_memo;
@property (nonatomic, retain) NSMutableDictionary *assignment_memo;
@property (nonatomic, retain) NSMutableDictionary *varPrefix_memo;
@property (nonatomic, retain) NSMutableDictionary *localVar_memo;
@property (nonatomic, retain) NSMutableDictionary *id_memo;
@property (nonatomic, retain) NSMutableDictionary *identifier_memo;
@property (nonatomic, retain) NSMutableDictionary *refinement_memo;
@property (nonatomic, retain) NSMutableDictionary *regexLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *regexBodyWith_memo;
@property (nonatomic, retain) NSMutableDictionary *regexMods_memo;
@property (nonatomic, retain) NSMutableDictionary *regex_memo;
@property (nonatomic, retain) NSMutableDictionary *regexWord_memo;
@property (nonatomic, retain) NSMutableDictionary *regexSymbol_memo;
@property (nonatomic, retain) NSMutableDictionary *saveStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *sendStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *atom_memo;
@property (nonatomic, retain) NSMutableDictionary *lines_memo;
@property (nonatomic, retain) NSMutableDictionary *line_memo;
@property (nonatomic, retain) NSMutableDictionary *eol_memo;
@end

@implementation ExpressionParser { }

- (instancetype)initWithDelegate:(id)d {
    self = [super initWithDelegate:d];
    if (self) {
            
  _tokens = [[NSMutableArray alloc] init];
  _match_tokens = [[NSMutableArray alloc] init];

        self.startRuleName = @"program";
        self.tokenKindTab[@"debuglevel"] = @(EXPRESSIONPARSER_TOKEN_KIND_DEBUGLEVEL);
        self.tokenKindTab[@"move"] = @(EXPRESSIONPARSER_TOKEN_KIND_MOVE);
        self.tokenKindTab[@":"] = @(EXPRESSIONPARSER_TOKEN_KIND_COLON);
        self.tokenKindTab[@"return"] = @(EXPRESSIONPARSER_TOKEN_KIND_RETURNSTMT);
        self.tokenKindTab[@"abort"] = @(EXPRESSIONPARSER_TOKEN_KIND_ABORT);
        self.tokenKindTab[@";"] = @(EXPRESSIONPARSER_TOKEN_KIND_SEMI_COLON);
        self.tokenKindTab[@"."] = @(EXPRESSIONPARSER_TOKEN_KIND_DOT);
        self.tokenKindTab[@"echo"] = @(EXPRESSIONPARSER_TOKEN_KIND_ECHO);
        self.tokenKindTab[@"pause"] = @(EXPRESSIONPARSER_TOKEN_KIND_PAUSE);
        self.tokenKindTab[@"/"] = @(EXPRESSIONPARSER_TOKEN_KIND_FORWARD_SLASH);
        self.tokenKindTab[@"put"] = @(EXPRESSIONPARSER_TOKEN_KIND_PUT);
        self.tokenKindTab[@"waitforre"] = @(EXPRESSIONPARSER_TOKEN_KIND_WAITFORRE);
        self.tokenKindTab[@"#"] = @(EXPRESSIONPARSER_TOKEN_KIND_POUND);
        self.tokenKindTab[@"matchwait"] = @(EXPRESSIONPARSER_TOKEN_KIND_MATCHWAIT);
        self.tokenKindTab[@"nextroom"] = @(EXPRESSIONPARSER_TOKEN_KIND_NEXTROOM);
        self.tokenKindTab[@"exit"] = @(EXPRESSIONPARSER_TOKEN_KIND_EXITSTMT);
        self.tokenKindTab[@"$"] = @(EXPRESSIONPARSER_TOKEN_KIND_DOLLAR);
        self.tokenKindTab[@"waitfor"] = @(EXPRESSIONPARSER_TOKEN_KIND_WAITFOR);
        self.tokenKindTab[@"resume"] = @(EXPRESSIONPARSER_TOKEN_KIND_RESUME);
        self.tokenKindTab[@"%"] = @(EXPRESSIONPARSER_TOKEN_KIND_PERCENT);
        self.tokenKindTab[@"script"] = @(EXPRESSIONPARSER_TOKEN_KIND_SCRIPT);
        self.tokenKindTab[@"send"] = @(EXPRESSIONPARSER_TOKEN_KIND_SEND);
        self.tokenKindTab[@"setvariable"] = @(EXPRESSIONPARSER_TOKEN_KIND_SETVARIABLE);
        self.tokenKindTab[@"matchre"] = @(EXPRESSIONPARSER_TOKEN_KIND_MATCHRE);
        self.tokenKindTab[@"^"] = @(EXPRESSIONPARSER_TOKEN_KIND_CARET);
        self.tokenKindTab[@"goto"] = @(EXPRESSIONPARSER_TOKEN_KIND_GOTO);
        self.tokenKindTab[@"gosub"] = @(EXPRESSIONPARSER_TOKEN_KIND_GOSUB);
        self.tokenKindTab[@"save"] = @(EXPRESSIONPARSER_TOKEN_KIND_SAVE);
        self.tokenKindTab[@"match"] = @(EXPRESSIONPARSER_TOKEN_KIND_MATCH);
        self.tokenKindTab[@"var"] = @(EXPRESSIONPARSER_TOKEN_KIND_VAR);

        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_DEBUGLEVEL] = @"debuglevel";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_MOVE] = @"move";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_COLON] = @":";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_RETURNSTMT] = @"return";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_ABORT] = @"abort";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_SEMI_COLON] = @";";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_ECHO] = @"echo";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_PAUSE] = @"pause";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_FORWARD_SLASH] = @"/";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_PUT] = @"put";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_WAITFORRE] = @"waitforre";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_POUND] = @"#";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_MATCHWAIT] = @"matchwait";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_NEXTROOM] = @"nextroom";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_EXITSTMT] = @"exit";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_DOLLAR] = @"$";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_WAITFOR] = @"waitfor";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_RESUME] = @"resume";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_PERCENT] = @"%";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_SCRIPT] = @"script";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_SEND] = @"send";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_SETVARIABLE] = @"setvariable";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_MATCHRE] = @"matchre";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_CARET] = @"^";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_GOTO] = @"goto";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_GOSUB] = @"gosub";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_SAVE] = @"save";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_MATCH] = @"match";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_VAR] = @"var";

        self.program_memo = [NSMutableDictionary dictionary];
        self.stmts_memo = [NSMutableDictionary dictionary];
        self.stmt_memo = [NSMutableDictionary dictionary];
        self.echoStmt_memo = [NSMutableDictionary dictionary];
        self.exitStmt_memo = [NSMutableDictionary dictionary];
        self.debuglevelStmt_memo = [NSMutableDictionary dictionary];
        self.gosubStmt_memo = [NSMutableDictionary dictionary];
        self.returnStmt_memo = [NSMutableDictionary dictionary];
        self.gotoStmt_memo = [NSMutableDictionary dictionary];
        self.matchStmt_memo = [NSMutableDictionary dictionary];
        self.matchreStmt_memo = [NSMutableDictionary dictionary];
        self.matchWaitStmt_memo = [NSMutableDictionary dictionary];
        self.moveStmt_memo = [NSMutableDictionary dictionary];
        self.nextRoom_memo = [NSMutableDictionary dictionary];
        self.pause_memo = [NSMutableDictionary dictionary];
        self.putCmds_memo = [NSMutableDictionary dictionary];
        self.putStmt_memo = [NSMutableDictionary dictionary];
        self.scriptAbort_memo = [NSMutableDictionary dictionary];
        self.scriptPause_memo = [NSMutableDictionary dictionary];
        self.scriptResume_memo = [NSMutableDictionary dictionary];
        self.commands_memo = [NSMutableDictionary dictionary];
        self.commandsExpr_memo = [NSMutableDictionary dictionary];
        self.waitForStmt_memo = [NSMutableDictionary dictionary];
        self.label_memo = [NSMutableDictionary dictionary];
        self.assignmentPrefix_memo = [NSMutableDictionary dictionary];
        self.assignment_memo = [NSMutableDictionary dictionary];
        self.varPrefix_memo = [NSMutableDictionary dictionary];
        self.localVar_memo = [NSMutableDictionary dictionary];
        self.id_memo = [NSMutableDictionary dictionary];
        self.identifier_memo = [NSMutableDictionary dictionary];
        self.refinement_memo = [NSMutableDictionary dictionary];
        self.regexLiteral_memo = [NSMutableDictionary dictionary];
        self.regexBodyWith_memo = [NSMutableDictionary dictionary];
        self.regexMods_memo = [NSMutableDictionary dictionary];
        self.regex_memo = [NSMutableDictionary dictionary];
        self.regexWord_memo = [NSMutableDictionary dictionary];
        self.regexSymbol_memo = [NSMutableDictionary dictionary];
        self.saveStmt_memo = [NSMutableDictionary dictionary];
        self.sendStmt_memo = [NSMutableDictionary dictionary];
        self.atom_memo = [NSMutableDictionary dictionary];
        self.lines_memo = [NSMutableDictionary dictionary];
        self.line_memo = [NSMutableDictionary dictionary];
        self.eol_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)clearMemo {
    [_program_memo removeAllObjects];
    [_stmts_memo removeAllObjects];
    [_stmt_memo removeAllObjects];
    [_echoStmt_memo removeAllObjects];
    [_exitStmt_memo removeAllObjects];
    [_debuglevelStmt_memo removeAllObjects];
    [_gosubStmt_memo removeAllObjects];
    [_returnStmt_memo removeAllObjects];
    [_gotoStmt_memo removeAllObjects];
    [_matchStmt_memo removeAllObjects];
    [_matchreStmt_memo removeAllObjects];
    [_matchWaitStmt_memo removeAllObjects];
    [_moveStmt_memo removeAllObjects];
    [_nextRoom_memo removeAllObjects];
    [_pause_memo removeAllObjects];
    [_putCmds_memo removeAllObjects];
    [_putStmt_memo removeAllObjects];
    [_scriptAbort_memo removeAllObjects];
    [_scriptPause_memo removeAllObjects];
    [_scriptResume_memo removeAllObjects];
    [_commands_memo removeAllObjects];
    [_commandsExpr_memo removeAllObjects];
    [_waitForStmt_memo removeAllObjects];
    [_label_memo removeAllObjects];
    [_assignmentPrefix_memo removeAllObjects];
    [_assignment_memo removeAllObjects];
    [_varPrefix_memo removeAllObjects];
    [_localVar_memo removeAllObjects];
    [_id_memo removeAllObjects];
    [_identifier_memo removeAllObjects];
    [_refinement_memo removeAllObjects];
    [_regexLiteral_memo removeAllObjects];
    [_regexBodyWith_memo removeAllObjects];
    [_regexMods_memo removeAllObjects];
    [_regex_memo removeAllObjects];
    [_regexWord_memo removeAllObjects];
    [_regexSymbol_memo removeAllObjects];
    [_saveStmt_memo removeAllObjects];
    [_sendStmt_memo removeAllObjects];
    [_atom_memo removeAllObjects];
    [_lines_memo removeAllObjects];
    [_line_memo removeAllObjects];
    [_eol_memo removeAllObjects];
}

- (void)start {

    [self program_]; 
    [self matchEOF:YES]; 

}

- (void)__program {
    
    [self execute:^{
    
  PKTokenizer *t = self.tokenizer;

  // whitespace
  //self.silentlyConsumesWhitespace = YES;
  //t.whitespaceState.reportsWhitespaceTokens = YES;
  //self.assembly.preservesWhitespaceTokens = YES;

  //[t.symbolState add:@"\n"];
  //[t.whitespaceState setWhitespaceChars:NO from:'n' to:'n'];

  [t.wordState setWordChars:YES from:'|' to:'|'];
  [t.wordState setWordChars:YES from:'.' to:'.'];
  //[t setTokenizerState:t.commentState from:'#' to:'#'];

  // setup comments
  t.commentState.reportsCommentTokens = YES;
  [t.commentState addSingleLineStartMarker:@"//"];
  [t.commentState addSingleLineStartMarker:@"#"];
  [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];

    }];
    [self stmts_]; 

    [self fireDelegateSelector:@selector(parser:didMatchProgram:)];
}

- (void)program_ {
    [self parseRule:@selector(__program) withMemo:_program_memo];
}

- (void)__stmts {
    
    [self stmt_]; 
    while ([self speculate:^{ [self match:EXPRESSIONPARSER_TOKEN_KIND_SEMI_COLON discard:YES]; [self stmt_]; }]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_SEMI_COLON discard:YES]; 
        [self stmt_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchStmts:)];
}

- (void)stmts_ {
    [self parseRule:@selector(__stmts) withMemo:_stmts_memo];
}

- (void)__stmt {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self label_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_PAUSE, 0]) {
        [self pause_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_SETVARIABLE, EXPRESSIONPARSER_TOKEN_KIND_VAR, 0]) {
        [self assignment_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_PUT, 0]) {
        [self putStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_SEND, 0]) {
        [self sendStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_ECHO, 0]) {
        [self echoStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_GOSUB, 0]) {
        [self gosubStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_RETURNSTMT, 0]) {
        [self returnStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_GOTO, 0]) {
        [self gotoStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_MOVE, 0]) {
        [self moveStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_NEXTROOM, 0]) {
        [self nextRoom_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_MATCH, 0]) {
        [self matchStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_MATCHRE, 0]) {
        [self matchreStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_MATCHWAIT, 0]) {
        [self matchWaitStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_WAITFOR, EXPRESSIONPARSER_TOKEN_KIND_WAITFORRE, 0]) {
        [self waitForStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_SAVE, 0]) {
        [self saveStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_EXITSTMT, 0]) {
        [self exitStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DEBUGLEVEL, 0]) {
        [self debuglevelStmt_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'stmt'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchStmt:)];
}

- (void)stmt_ {
    [self parseRule:@selector(__stmt) withMemo:_stmt_memo];
}

- (void)__echoStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_ECHO discard:YES]; 
    while ([self speculate:^{ [self atom_]; }]) {
        [self atom_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchEchoStmt:)];
}

- (void)echoStmt_ {
    [self parseRule:@selector(__echoStmt) withMemo:_echoStmt_memo];
}

- (void)__exitStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_EXITSTMT discard:YES]; 

    [self fireDelegateSelector:@selector(parser:didMatchExitStmt:)];
}

- (void)exitStmt_ {
    [self parseRule:@selector(__exitStmt) withMemo:_exitStmt_memo];
}

- (void)__debuglevelStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_DEBUGLEVEL discard:NO]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self matchNumber:NO]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchDebuglevelStmt:)];
}

- (void)debuglevelStmt_ {
    [self parseRule:@selector(__debuglevelStmt) withMemo:_debuglevelStmt_memo];
}

- (void)__gosubStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_GOSUB discard:YES]; 
    [self id_]; 
    while ([self speculate:^{ if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {[self id_]; } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, 0]) {[self localVar_]; } else {[self raise:@"No viable alternative found in rule 'gosubStmt'."];}}]) {
        if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self id_]; 
        } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, 0]) {
            [self localVar_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'gosubStmt'."];
        }
    }

    [self fireDelegateSelector:@selector(parser:didMatchGosubStmt:)];
}

- (void)gosubStmt_ {
    [self parseRule:@selector(__gosubStmt) withMemo:_gosubStmt_memo];
}

- (void)__returnStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_RETURNSTMT discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchReturnStmt:)];
}

- (void)returnStmt_ {
    [self parseRule:@selector(__returnStmt) withMemo:_returnStmt_memo];
}

- (void)__gotoStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_GOTO discard:YES]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self id_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, 0]) {
        [self localVar_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'gotoStmt'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchGotoStmt:)];
}

- (void)gotoStmt_ {
    [self parseRule:@selector(__gotoStmt) withMemo:_gotoStmt_memo];
}

- (void)__matchStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_MATCH discard:YES]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self id_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, 0]) {
        [self localVar_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'matchStmt'."];
    }
    do {
        if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self atom_]; 
        } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOT, 0]) {
            [self match:EXPRESSIONPARSER_TOKEN_KIND_DOT discard:NO]; 
        } else {
            [self raise:@"No viable alternative found in rule 'matchStmt'."];
        }
    } while ([self speculate:^{ if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_WORD, 0]) {[self atom_]; } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOT, 0]) {[self match:EXPRESSIONPARSER_TOKEN_KIND_DOT discard:NO]; } else {[self raise:@"No viable alternative found in rule 'matchStmt'."];}}]);

    [self fireDelegateSelector:@selector(parser:didMatchMatchStmt:)];
}

- (void)matchStmt_ {
    [self parseRule:@selector(__matchStmt) withMemo:_matchStmt_memo];
}

- (void)__matchreStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_MATCHRE discard:YES]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self id_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, 0]) {
        [self localVar_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'matchreStmt'."];
    }
    do {
        [self regex_]; 
    } while ([self speculate:^{ [self regex_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchMatchreStmt:)];
}

- (void)matchreStmt_ {
    [self parseRule:@selector(__matchreStmt) withMemo:_matchreStmt_memo];
}

- (void)__matchWaitStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_MATCHWAIT discard:YES]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self matchNumber:NO]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchMatchWaitStmt:)];
}

- (void)matchWaitStmt_ {
    [self parseRule:@selector(__matchWaitStmt) withMemo:_matchWaitStmt_memo];
}

- (void)__moveStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_MOVE discard:YES]; 
    do {
        [self atom_]; 
    } while ([self speculate:^{ [self atom_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchMoveStmt:)];
}

- (void)moveStmt_ {
    [self parseRule:@selector(__moveStmt) withMemo:_moveStmt_memo];
}

- (void)__nextRoom {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_NEXTROOM discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchNextRoom:)];
}

- (void)nextRoom_ {
    [self parseRule:@selector(__nextRoom) withMemo:_nextRoom_memo];
}

- (void)__pause {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_PAUSE discard:YES]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self matchNumber:NO]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchPause:)];
}

- (void)pause_ {
    [self parseRule:@selector(__pause) withMemo:_pause_memo];
}

- (void)__putCmds {
    
    if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_POUND, 0]) {
        [self commandsExpr_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self atom_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'putCmds'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchPutCmds:)];
}

- (void)putCmds_ {
    [self parseRule:@selector(__putCmds) withMemo:_putCmds_memo];
}

- (void)__putStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_PUT discard:YES]; 
    if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_PUT, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_PUT discard:NO]; 
    }
    do {
        [self putCmds_]; 
    } while ([self speculate:^{ [self putCmds_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchPutStmt:)];
}

- (void)putStmt_ {
    [self parseRule:@selector(__putStmt) withMemo:_putStmt_memo];
}

- (void)__scriptAbort {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_SCRIPT discard:NO]; 
    [self match:EXPRESSIONPARSER_TOKEN_KIND_ABORT discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchScriptAbort:)];
}

- (void)scriptAbort_ {
    [self parseRule:@selector(__scriptAbort) withMemo:_scriptAbort_memo];
}

- (void)__scriptPause {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_SCRIPT discard:NO]; 
    [self match:EXPRESSIONPARSER_TOKEN_KIND_PAUSE discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchScriptPause:)];
}

- (void)scriptPause_ {
    [self parseRule:@selector(__scriptPause) withMemo:_scriptPause_memo];
}

- (void)__scriptResume {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_SCRIPT discard:NO]; 
    [self match:EXPRESSIONPARSER_TOKEN_KIND_RESUME discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchScriptResume:)];
}

- (void)scriptResume_ {
    [self parseRule:@selector(__scriptResume) withMemo:_scriptResume_memo];
}

- (void)__commands {
    
    if ([self speculate:^{ [self scriptResume_]; }]) {
        [self scriptResume_]; 
    } else if ([self speculate:^{ [self scriptAbort_]; }]) {
        [self scriptAbort_]; 
    } else if ([self speculate:^{ [self scriptPause_]; }]) {
        [self scriptPause_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'commands'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchCommands:)];
}

- (void)commands_ {
    [self parseRule:@selector(__commands) withMemo:_commands_memo];
}

- (void)__commandsExpr {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_POUND discard:NO]; 
    [self commands_]; 
    do {
        [self atom_]; 
    } while ([self speculate:^{ [self atom_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchCommandsExpr:)];
}

- (void)commandsExpr_ {
    [self parseRule:@selector(__commandsExpr) withMemo:_commandsExpr_memo];
}

- (void)__waitForStmt {
    
    if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_WAITFOR, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_WAITFOR discard:YES]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_WAITFORRE, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_WAITFORRE discard:YES]; 
    } else {
        [self raise:@"No viable alternative found in rule 'waitForStmt'."];
    }
    do {
        if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self atom_]; 
        } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_CARET, 0]) {
            [self regex_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'waitForStmt'."];
        }
    } while ([self speculate:^{ if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_WORD, 0]) {[self atom_]; } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_CARET, 0]) {[self regex_]; } else {[self raise:@"No viable alternative found in rule 'waitForStmt'."];}}]);

    [self fireDelegateSelector:@selector(parser:didMatchWaitForStmt:)];
}

- (void)waitForStmt_ {
    [self parseRule:@selector(__waitForStmt) withMemo:_waitForStmt_memo];
}

- (void)__label {
    
    [self id_]; 
    [self match:EXPRESSIONPARSER_TOKEN_KIND_COLON discard:YES]; 

    [self fireDelegateSelector:@selector(parser:didMatchLabel:)];
}

- (void)label_ {
    [self parseRule:@selector(__label) withMemo:_label_memo];
}

- (void)__assignmentPrefix {
    
    if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_VAR, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_VAR discard:YES]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_SETVARIABLE, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_SETVARIABLE discard:YES]; 
    } else {
        [self raise:@"No viable alternative found in rule 'assignmentPrefix'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchAssignmentPrefix:)];
}

- (void)assignmentPrefix_ {
    [self parseRule:@selector(__assignmentPrefix) withMemo:_assignmentPrefix_memo];
}

- (void)__assignment {
    
    [self assignmentPrefix_]; 
    [self id_]; 
    do {
        [self atom_]; 
    } while ([self speculate:^{ [self atom_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchAssignment:)];
}

- (void)assignment_ {
    [self parseRule:@selector(__assignment) withMemo:_assignment_memo];
}

- (void)__varPrefix {
    
    if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_PERCENT, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_PERCENT discard:NO]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'varPrefix'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchVarPrefix:)];
}

- (void)varPrefix_ {
    [self parseRule:@selector(__varPrefix) withMemo:_varPrefix_memo];
}

- (void)__localVar {
    
    if ([self speculate:^{ [self varPrefix_]; [self id_]; }]) {
        [self varPrefix_]; 
        [self id_]; 
    } else if ([self speculate:^{ [self varPrefix_]; [self matchNumber:NO]; }]) {
        [self varPrefix_]; 
        [self matchNumber:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'localVar'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchLocalVar:)];
}

- (void)localVar_ {
    [self parseRule:@selector(__localVar) withMemo:_localVar_memo];
}

- (void)__id {
    
    if ([self speculate:^{ [self identifier_]; [self refinement_]; while ([self speculate:^{ [self refinement_]; }]) {[self refinement_]; }}]) {
        [self identifier_]; 
        [self refinement_]; 
        while ([self speculate:^{ [self refinement_]; }]) {
            [self refinement_]; 
        }
    } else if ([self speculate:^{ [self identifier_]; }]) {
        [self identifier_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'id'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchId:)];
}

- (void)id_ {
    [self parseRule:@selector(__id) withMemo:_id_memo];
}

- (void)__identifier {
    
    [self testAndThrow:(id)^{ return MATCHES(@"[a-zA-Z_]+[a-zA-Z0-9\\._]+", LS(1)); }];
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchIdentifier:)];
}

- (void)identifier_ {
    [self parseRule:@selector(__identifier) withMemo:_identifier_memo];
}

- (void)__refinement {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_DOT discard:NO]; 
    [self identifier_]; 

    [self fireDelegateSelector:@selector(parser:didMatchRefinement:)];
}

- (void)refinement_ {
    [self parseRule:@selector(__refinement) withMemo:_refinement_memo];
}

- (void)__regexLiteral {
    
    if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_FORWARD_SLASH, 0]) {
        [self regexBodyWith_]; 
        if ([self speculate:^{ [self regexMods_]; }]) {
            [self regexMods_]; 
        }
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_CARET, 0]) {
        [self regex_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'regexLiteral'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchRegexLiteral:)];
}

- (void)regexLiteral_ {
    [self parseRule:@selector(__regexLiteral) withMemo:_regexLiteral_memo];
}

- (void)__regexBodyWith {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_FORWARD_SLASH discard:NO]; 
    [self regex_]; 
    [self match:EXPRESSIONPARSER_TOKEN_KIND_FORWARD_SLASH discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchRegexBodyWith:)];
}

- (void)regexBodyWith_ {
    [self parseRule:@selector(__regexBodyWith) withMemo:_regexBodyWith_memo];
}

- (void)__regexMods {
    
    [self testAndThrow:(id)^{ return MATCHES_IGNORE_CASE(@"[imxs]+", LS(1)); }]; 
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchRegexMods:)];
}

- (void)regexMods_ {
    [self parseRule:@selector(__regexMods) withMemo:_regexMods_memo];
}

- (void)__regex {
    
    if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_CARET, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_CARET discard:NO]; 
    }
    do {
        if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_COLON, TOKEN_KIND_BUILTIN_SYMBOL, 0]) {
            [self regexSymbol_]; 
        } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self regexWord_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'regex'."];
        }
    } while ([self speculate:^{ if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_COLON, TOKEN_KIND_BUILTIN_SYMBOL, 0]) {[self regexSymbol_]; } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {[self regexWord_]; } else {[self raise:@"No viable alternative found in rule 'regex'."];}}]);
    if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR discard:NO]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchRegex:)];
}

- (void)regex_ {
    [self parseRule:@selector(__regex) withMemo:_regex_memo];
}

- (void)__regexWord {
    
    [self testAndThrow:(id)^{ return MATCHES(@"\\S", LS(1)); }];
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchRegexWord:)];
}

- (void)regexWord_ {
    [self parseRule:@selector(__regexWord) withMemo:_regexWord_memo];
}

- (void)__regexSymbol {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_SYMBOL, 0]) {
        [self matchSymbol:NO]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_COLON, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_COLON discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'regexSymbol'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchRegexSymbol:)];
}

- (void)regexSymbol_ {
    [self parseRule:@selector(__regexSymbol) withMemo:_regexSymbol_memo];
}

- (void)__saveStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_SAVE discard:YES]; 
    do {
        [self atom_]; 
    } while ([self speculate:^{ [self atom_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchSaveStmt:)];
}

- (void)saveStmt_ {
    [self parseRule:@selector(__saveStmt) withMemo:_saveStmt_memo];
}

- (void)__sendStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_SEND discard:YES]; 
    do {
        [self atom_]; 
    } while ([self speculate:^{ [self atom_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchSendStmt:)];
}

- (void)sendStmt_ {
    [self parseRule:@selector(__sendStmt) withMemo:_sendStmt_memo];
}

- (void)__atom {
    
    if ([self speculate:^{ [self localVar_]; }]) {
        [self localVar_]; 
    } else if ([self speculate:^{ [self id_]; }]) {
        [self id_]; 
    } else if ([self speculate:^{ [self matchWord:NO]; }]) {
        [self matchWord:NO]; 
    } else if ([self speculate:^{ [self matchNumber:NO]; }]) {
        [self matchNumber:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'atom'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchAtom:)];
}

- (void)atom_ {
    [self parseRule:@selector(__atom) withMemo:_atom_memo];
}

- (void)__lines {
    
    do {
        [self line_]; 
    } while ([self speculate:^{ [self line_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchLines:)];
}

- (void)lines_ {
    [self parseRule:@selector(__lines) withMemo:_lines_memo];
}

- (void)__line {
    
    while ([self speculate:^{ if (![self speculate:^{ [self eol_]; }]) {[self match:TOKEN_KIND_BUILTIN_ANY discard:NO];} else {[self raise:@"negation test failed in line"];}}]) {
        if (![self speculate:^{ [self eol_]; }]) {
            [self match:TOKEN_KIND_BUILTIN_ANY discard:NO];
        } else {
            [self raise:@"negation test failed in line"];
        }
    }
    [self eol_]; 

    [self fireDelegateSelector:@selector(parser:didMatchLine:)];
}

- (void)line_ {
    [self parseRule:@selector(__line) withMemo:_line_memo];
}

- (void)__eol {
    
    [self testAndThrow:(id)^{ return MATCHES(@"\n", LS(1)); }]; 
    [self matchWhitespace:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchEol:)];
}

- (void)eol_ {
    [self parseRule:@selector(__eol) withMemo:_eol_memo];
}

@end