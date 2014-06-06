#import "ExpressionParser.h"
#import <PEGKit/PEGKit.h>


@interface ExpressionParser ()

@property (nonatomic, retain) NSMutableDictionary *program_memo;
@property (nonatomic, retain) NSMutableDictionary *stmts_memo;
@property (nonatomic, retain) NSMutableDictionary *stmt_memo;
@property (nonatomic, retain) NSMutableDictionary *echoStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *exitStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *gotoStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *matchStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *matchWaitStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *moveStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *nextRoom_memo;
@property (nonatomic, retain) NSMutableDictionary *pause_memo;
@property (nonatomic, retain) NSMutableDictionary *putStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *waitForStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *label_memo;
@property (nonatomic, retain) NSMutableDictionary *assignmentPrefix_memo;
@property (nonatomic, retain) NSMutableDictionary *assignment_memo;
@property (nonatomic, retain) NSMutableDictionary *varPrefix_memo;
@property (nonatomic, retain) NSMutableDictionary *localVar_memo;
@property (nonatomic, retain) NSMutableDictionary *id_memo;
@property (nonatomic, retain) NSMutableDictionary *identifier_memo;
@property (nonatomic, retain) NSMutableDictionary *refinement_memo;
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
        self.enableAutomaticErrorRecovery = YES;

        self.tokenKindTab[@":"] = @(EXPRESSIONPARSER_TOKEN_KIND_COLON);
        self.tokenKindTab[@"matchwait"] = @(EXPRESSIONPARSER_TOKEN_KIND_MATCHWAIT);
        self.tokenKindTab[@";"] = @(EXPRESSIONPARSER_TOKEN_KIND_SEMI_COLON);
        self.tokenKindTab[@"setvariable"] = @(EXPRESSIONPARSER_TOKEN_KIND_SETVARIABLE);
        self.tokenKindTab[@"$"] = @(EXPRESSIONPARSER_TOKEN_KIND_DOLLAR);
        self.tokenKindTab[@"var"] = @(EXPRESSIONPARSER_TOKEN_KIND_VAR);
        self.tokenKindTab[@"match"] = @(EXPRESSIONPARSER_TOKEN_KIND_MATCH);
        self.tokenKindTab[@"echo"] = @(EXPRESSIONPARSER_TOKEN_KIND_ECHO);
        self.tokenKindTab[@"goto"] = @(EXPRESSIONPARSER_TOKEN_KIND_GOTO);
        self.tokenKindTab[@"exit"] = @(EXPRESSIONPARSER_TOKEN_KIND_EXITSTMT);
        self.tokenKindTab[@"matchre"] = @(EXPRESSIONPARSER_TOKEN_KIND_MATCHRE);
        self.tokenKindTab[@"%"] = @(EXPRESSIONPARSER_TOKEN_KIND_PERCENT);
        self.tokenKindTab[@"."] = @(EXPRESSIONPARSER_TOKEN_KIND_DOT);
        self.tokenKindTab[@"nextroom"] = @(EXPRESSIONPARSER_TOKEN_KIND_NEXTROOM);
        self.tokenKindTab[@"move"] = @(EXPRESSIONPARSER_TOKEN_KIND_MOVE);
        self.tokenKindTab[@"pause"] = @(EXPRESSIONPARSER_TOKEN_KIND_PAUSE);
        self.tokenKindTab[@"put"] = @(EXPRESSIONPARSER_TOKEN_KIND_PUT);
        self.tokenKindTab[@"waitfor"] = @(EXPRESSIONPARSER_TOKEN_KIND_WAITFOR);
        self.tokenKindTab[@"waitforre"] = @(EXPRESSIONPARSER_TOKEN_KIND_WAITFORRE);

        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_COLON] = @":";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_MATCHWAIT] = @"matchwait";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_SEMI_COLON] = @";";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_SETVARIABLE] = @"setvariable";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_DOLLAR] = @"$";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_VAR] = @"var";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_MATCH] = @"match";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_ECHO] = @"echo";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_GOTO] = @"goto";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_EXITSTMT] = @"exit";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_MATCHRE] = @"matchre";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_PERCENT] = @"%";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_NEXTROOM] = @"nextroom";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_MOVE] = @"move";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_PAUSE] = @"pause";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_PUT] = @"put";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_WAITFOR] = @"waitfor";
        self.tokenKindNameTab[EXPRESSIONPARSER_TOKEN_KIND_WAITFORRE] = @"waitforre";

        self.program_memo = [NSMutableDictionary dictionary];
        self.stmts_memo = [NSMutableDictionary dictionary];
        self.stmt_memo = [NSMutableDictionary dictionary];
        self.echoStmt_memo = [NSMutableDictionary dictionary];
        self.exitStmt_memo = [NSMutableDictionary dictionary];
        self.gotoStmt_memo = [NSMutableDictionary dictionary];
        self.matchStmt_memo = [NSMutableDictionary dictionary];
        self.matchWaitStmt_memo = [NSMutableDictionary dictionary];
        self.moveStmt_memo = [NSMutableDictionary dictionary];
        self.nextRoom_memo = [NSMutableDictionary dictionary];
        self.pause_memo = [NSMutableDictionary dictionary];
        self.putStmt_memo = [NSMutableDictionary dictionary];
        self.waitForStmt_memo = [NSMutableDictionary dictionary];
        self.label_memo = [NSMutableDictionary dictionary];
        self.assignmentPrefix_memo = [NSMutableDictionary dictionary];
        self.assignment_memo = [NSMutableDictionary dictionary];
        self.varPrefix_memo = [NSMutableDictionary dictionary];
        self.localVar_memo = [NSMutableDictionary dictionary];
        self.id_memo = [NSMutableDictionary dictionary];
        self.identifier_memo = [NSMutableDictionary dictionary];
        self.refinement_memo = [NSMutableDictionary dictionary];
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
    [_gotoStmt_memo removeAllObjects];
    [_matchStmt_memo removeAllObjects];
    [_matchWaitStmt_memo removeAllObjects];
    [_moveStmt_memo removeAllObjects];
    [_nextRoom_memo removeAllObjects];
    [_pause_memo removeAllObjects];
    [_putStmt_memo removeAllObjects];
    [_waitForStmt_memo removeAllObjects];
    [_label_memo removeAllObjects];
    [_assignmentPrefix_memo removeAllObjects];
    [_assignment_memo removeAllObjects];
    [_varPrefix_memo removeAllObjects];
    [_localVar_memo removeAllObjects];
    [_id_memo removeAllObjects];
    [_identifier_memo removeAllObjects];
    [_refinement_memo removeAllObjects];
    [_atom_memo removeAllObjects];
    [_lines_memo removeAllObjects];
    [_line_memo removeAllObjects];
    [_eol_memo removeAllObjects];
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
    
    [self execute:^{
    
  PKTokenizer *t = self.tokenizer;

  // whitespace
  self.silentlyConsumesWhitespace = YES;
  t.whitespaceState.reportsWhitespaceTokens = YES;
  //self.assembly.preservesWhitespaceTokens = YES;

  //[t.symbolState add:@"\n"];
  //[t.whitespaceState setWhitespaceChars:NO from:'n' to:'n'];

  
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
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_ECHO, 0]) {
        [self echoStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_GOTO, 0]) {
        [self gotoStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_MOVE, 0]) {
        [self moveStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_NEXTROOM, 0]) {
        [self nextRoom_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_MATCH, EXPRESSIONPARSER_TOKEN_KIND_MATCHRE, 0]) {
        [self matchStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_MATCHWAIT, 0]) {
        [self matchWaitStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_WAITFOR, EXPRESSIONPARSER_TOKEN_KIND_WAITFORRE, 0]) {
        [self waitForStmt_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_EXITSTMT, 0]) {
        [self exitStmt_]; 
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
    
    if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_MATCH, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_MATCH discard:YES]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_MATCHRE, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_MATCHRE discard:YES]; 
    } else {
        [self raise:@"No viable alternative found in rule 'matchStmt'."];
    }
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self id_]; 
    } else if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOLLAR, EXPRESSIONPARSER_TOKEN_KIND_PERCENT, 0]) {
        [self localVar_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'matchStmt'."];
    }
    do {
        [self atom_]; 
    } while ([self speculate:^{ [self atom_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchMatchStmt:)];
}

- (void)matchStmt_ {
    [self parseRule:@selector(__matchStmt) withMemo:_matchStmt_memo];
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
    [self atom_]; 

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

- (void)__putStmt {
    
    [self match:EXPRESSIONPARSER_TOKEN_KIND_PUT discard:YES]; 
    do {
        [self atom_]; 
    } while ([self speculate:^{ [self atom_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchPutStmt:)];
}

- (void)putStmt_ {
    [self parseRule:@selector(__putStmt) withMemo:_putStmt_memo];
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
        [self atom_]; 
    } while ([self speculate:^{ [self atom_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchWaitForStmt:)];
}

- (void)waitForStmt_ {
    [self parseRule:@selector(__waitForStmt) withMemo:_waitForStmt_memo];
}

- (void)__label {
    
    [self tryAndRecover:EXPRESSIONPARSER_TOKEN_KIND_COLON block:^{ 
        [self id_]; 
        [self match:EXPRESSIONPARSER_TOKEN_KIND_COLON discard:YES]; 
    } completion:^{ 
        [self match:EXPRESSIONPARSER_TOKEN_KIND_COLON discard:YES]; 
    }];

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
    
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchIdentifier:)];
}

- (void)identifier_ {
    [self parseRule:@selector(__identifier) withMemo:_identifier_memo];
}

- (void)__refinement {
    
    if ([self predicts:EXPRESSIONPARSER_TOKEN_KIND_DOT, 0]) {
        [self match:EXPRESSIONPARSER_TOKEN_KIND_DOT discard:NO]; 
        [self identifier_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self matchNumber:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'refinement'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchRefinement:)];
}

- (void)refinement_ {
    [self parseRule:@selector(__refinement) withMemo:_refinement_memo];
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