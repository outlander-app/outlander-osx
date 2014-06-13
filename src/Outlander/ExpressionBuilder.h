//
//  ExpressionBuilder.h
//  Outlander
//
//  Created by Joseph McBride on 6/4/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <PEGKit/PEGKit.h>
#import "AssignmentToken.h"
#import "Atom.h"
#import "CommandsToken.h"
#import "EchoToken.h"
#import "ExitToken.h"
#import "GosubToken.h"
#import "GotoToken.h"
#import "DebugLevelToken.h"
#import "IdToken.h"
#import "LabelToken.h"
#import "MatchToken.h"
#import "MatchWaitToken.h"
#import "MoveToken.h"
#import "NextRoomToken.h"
#import "PauseToken.h"
#import "PutToken.h"
#import "RegexToken.h"
#import "ReturnToken.h"
#import "SendToken.h"
#import "VarToken.h"
#import "WaitToken.h"
#import "WaitForToken.h"

@interface ExpressionBuilder : NSObject

-(NSArray *)build:(NSString *)data;

-(NSArray *)matchTokens;

@end
