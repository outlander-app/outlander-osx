//
//  GameParser.m
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameParser.h"
#import "Shared.h"
#import "HTMLNode.h"
#import "HTMLParser.h"
#import "TextTag.h"
#import "Vitals.h"
#import "SkillExp.h"
#import "LearningRate.h"
#import "Roundtime.h"
#import "NSString+Categories.h"

@implementation GameParser {
    NSArray *_roomTags;
    GameContext *_gameContext;
}

-(id)initWithContext:(GameContext *)context {
    self = [super init];
    if(self == nil) return nil;
    
    _gameContext = context;
    
    _subject = [RACReplaySubject subject];
    _vitals = [RACReplaySubject subject];
    _room = [RACReplaySubject subject];
    _exp = [RACReplaySubject subject];
    _thoughts = [RACReplaySubject subject];
    _arrivals = [RACReplaySubject subject];
    _deaths = [RACReplaySubject subject];
    _familiar = [RACReplaySubject subject];
    _log = [RACReplaySubject subject];
    _roundtime = [RACReplaySubject subject];
    _currenList = [[NSMutableArray alloc] init];
    _currentResult = [[NSMutableString alloc] init];
    _inStream = NO;
    _publishStream = YES;
    _bold = NO;
    _mono = NO;
    
    _roomTags = @[@"roomdesc", @"roomobjs", @"roomplayers", @"roomexits"];
    
    return self;
}

-(void) parse:(NSString*)data then:(CompleteBlock)block {
    NSError *error = nil;
    
    if(data == nil) return;
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:data];
    
    [str replaceOccurrencesOfString:@"<style id=\"\"/>" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<d>" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<d/>" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<b>" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<b/>" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    
    if([str hasPrefix:@"&lt;"] || [str hasPrefix:@"*"]) {
        NSRange range = [data rangeOfString:@"<pushBold"];
        if(range.location != NSNotFound) {
            [str insertString:@"<p>" atIndex:0];
            [str insertString:@"</p>" atIndex:range.location + 1];
        }
    }
    
    if([str length] == 0) return;
    
    if(![str containsString:@"<"]) {
        [str insertString:@"<pre>" atIndex:0];
        [str insertString:@"</pre>" atIndex:[str length]];
    }
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:str error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser body];
    NSArray *children = [bodyNode children];
    NSUInteger count = [children count];
//    NSLog(@"Children Count: %lu", count);
    
    for (__block NSInteger i=0; i<count; i++) {
        HTMLNode *node = children[i];
        NSString * tagName = [node tagName];
//        NSLog(@"%@", tagName);
        if([tagName isEqualToString:@"prompt"]){
            NSString *time = [node getAttributeNamed:@"time"];
            NSString *prompt = [[node contents] trimWhitespaceAndNewline];
            
            [_gameContext.globalVars setCacheObject:prompt forKey:@"prompt"];
            [_gameContext.globalVars setCacheObject:time forKey:@"gametime"];
            
            NSTimeInterval today = [[NSDate date] timeIntervalSince1970];
            NSString *intervalString = [NSString stringWithFormat:@"%f", today];
            [_gameContext.globalVars setCacheObject:intervalString forKey:@"gametimeupdate"];
            
            [_currentResult appendString:prompt];
        }
        else if([tagName isEqualToString:@"roundtime"]) {
            
            NSString *time = [node getAttributeNamed:@"value"];
            
            Roundtime *rt = [[Roundtime alloc] init];
            rt.time =[ NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
            
            [_roundtime sendNext:rt];
            
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"pushstream"]) {
            _inStream = YES;
            _streamId = [node getAttributeNamed:@"id"];
            if([_streamId isEqualToString:@"inv"] || [_streamId isEqualToString:@"talk"]) _publishStream = NO;
            else _publishStream = YES;
            
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"popstream"]) {
            if([_streamId isEqual: @"logons"]) {
                TextTag *tag = [TextTag tagFor:[_currentResult trimNewLine] mono:_mono];
                [_arrivals sendNext:tag];
                [_currentResult setString:@""];
            }
            else if([_streamId isEqual: @"death"]) {
                TextTag *tag = [TextTag tagFor:[_currentResult trimNewLine] mono:_mono];
                [_deaths sendNext:tag];
                [_currentResult setString:@""];
            }
            else if([_streamId isEqual: @"thoughts"]) {
                TextTag *tag = [TextTag tagFor:[_currentResult trimNewLine] mono:_mono];
                [_thoughts sendNext:tag];
                [_currentResult setString:@""];
            }
            
            _inStream = NO;
            _streamId = nil;
            _publishStream = YES;
            
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"spell"]) {
            [_gameContext.globalVars setCacheObject:[node contents] forKey:@"spell"];
            
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"left"]) {
            NSString *val = [node contents];
            [_gameContext.globalVars setCacheObject:val forKey:@"lefthand"];
            [_gameContext.globalVars setCacheObject:[node getAttributeNamed:@"exist"] forKey:@"lefthandid"];
            [_gameContext.globalVars setCacheObject:[node getAttributeNamed:@"noun"] forKey:@"lefthandnoun"];

            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"right"]) {
            NSString *val = [node contents];
            [_gameContext.globalVars setCacheObject:val forKey:@"righthand"];
            [_gameContext.globalVars setCacheObject:[node getAttributeNamed:@"exist"] forKey:@"righthandid"];
            [_gameContext.globalVars setCacheObject:[node getAttributeNamed:@"noun"] forKey:@"righthandnoun"];

            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"clearstream"]) {
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"pushbold"]) {
            if([_currentResult length] > 0){
                TextTag *tag = [TextTag tagFor:[NSString stringWithString:_currentResult] mono:_mono];
                [_currentResult setString:@""];
                [_currenList addObject:tag];
            }
            _bold = YES;
        }
        else if([tagName isEqualToString:@"popbold"]) {
            if([_currentResult length] > 0){
                TextTag *tag = [TextTag tagFor:[NSString stringWithString:_currentResult] mono:_mono];
                tag.color = @"#FFFF00";
                [_currentResult setString:@""];
                [_currenList addObject:tag];
            }
            _bold = NO;
        }
        else if([tagName isEqualToString:@"component"]) {
            NSString *compId = [node getAttributeNamed:@"id"];
            
            if (compId != nil && [compId length] >-0) {
                if([compId hasPrefix:@"exp"]) {
                    compId = [compId stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                }
                else {
                    compId = [compId stringByReplacingOccurrencesOfString:@" " withString:@""];
                }
                
                NSString *raw = [node allContents];
                
                if([compId hasPrefix:@"exp_tdp"]){
                    [self parseTdp:raw];
                }
                else if([compId hasPrefix:@"exp"]) {
                    BOOL isNew = NO;
                    if(node.children.count > 0) {
                        HTMLNode *childNode = node.children[0];
                        isNew = [[childNode getAttributeNamed:@"id"] isEqualToString:@"whisper"];
                    }
                    [self parseExp:compId withData:raw isNew:isNew];
                }
                else {
                
                    [_gameContext.globalVars setCacheObject:raw forKey:compId];
                
                    if([_roomTags containsObject:compId]) {
                        [_room sendNext:@""];
                    }
                }
            }
            
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"compdef"]) {
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"style"]) {
            
            NSString *attr = [node getAttributeNamed:@"id"];
            if ([attr isEqualToString:@"roomName"]){
                HTMLNode *roomnode = children[i+1];
                NSString *val = [roomnode rawContents];
                [_gameContext.globalVars setCacheObject:[val trimNewLine] forKey:@"roomname"];
                TextTag *tag = [TextTag tagFor:[NSString stringWithString:val] mono:_mono];
                tag.color = @"#0000FF";
                [_currenList addObject:tag];
                i++;
            }
            
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"dialogdata"]) {
            
            HTMLNode *progressTag = [node findChildTag:@"progressbar"];
            
            if(progressTag != nil) {
                NSString *name = [progressTag getAttributeNamed:@"id"];
                NSString *stringValue = [progressTag getAttributeNamed:@"value"];
                UInt16 value = [self numberFrom:stringValue];
                
                Vitals *vitals = [[Vitals alloc] initWith:name value:value];
                
                [_gameContext.globalVars setCacheObject:stringValue forKey:name];
                
                [_vitals sendNext:vitals];
            }
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"opendialog"]) {
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"switchquickbar"]) {
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"streamwindow"]) {
            
            if([[node getAttributeNamed:@"id"] isEqualToString:@"room"]) {
                NSString *subtitle = [node getAttributeNamed:@"subtitle"];
                NSString *name = @"";
                if(subtitle != nil && subtitle.length > 3){
                    name = [subtitle substringFromIndex:3];
                }
                [_gameContext.globalVars setCacheObject:name forKey:@"roomtitle"];
                [_room sendNext:@""];
            }
            
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"indicator"]) {
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"nav"]) {
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"mode"]) {
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"app"]) {
            
            [_gameContext.globalVars setCacheObject:[node getAttributeNamed:@"game"] forKey:@"game"];
            [_gameContext.globalVars setCacheObject:[node getAttributeNamed:@"char"] forKey:@"charactername"];
            
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"endsetup"]) {
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"output"]) {
            NSString *attr = [node getAttributeNamed:@"class"];
            if([attr isEqual: @"mono"]) _mono = YES;
            else _mono = NO;
            if([self isNextNodeNewline:children index:i]) {
                i++;
            }
        }
        else if([tagName isEqualToString:@"preset"]){
            NSString *val = [node contents];
            NSString *attr = [node getAttributeNamed:@"id"];
            
            if([attr isEqualToString:@"roomDesc"]) {
                [_gameContext.globalVars setCacheObject:val forKey:@"roomdesc"];
            }
            
            if(![_streamId isEqualToString:@"talk"]) {
                [_currentResult appendString:val];
            }
        }
        else if([tagName isEqualToString:@"p"]){
            NSString *val = [node contents];
            NSLog(@"raw: %@", [node rawContents]);
            [_currentResult appendString:val];
        }
        else if([tagName isEqualToString:@"pre"]){
            if(!_publishStream) {
                if([self isNextNodeNewline:children index:i]) {
                    i++;
                }
                continue;
            }
            
            NSString *val = [node contents];
            NSLog(@"%@", [node rawContents]);
            [_currentResult appendString:val];
        }
        else if([tagName isEqualToString:@"text"]){
            if(!_publishStream) {
                if([self isNextNodeNewline:children index:i]) {
                    i++;
                }
                continue;
            }
            
            NSString *val = [node rawContents];
            NSLog(@"text:%@", val);
            
            if([val hasPrefix:@"  You also see"]) {
                [_currentResult appendString:@"\n"];
                [_currentResult appendString:[val substringFromIndex:2]];
            } else {
                [_currentResult appendString:val];
            }
        }
    }
    if(!_inStream && [_currentResult length] > 0){
        TextTag *tag = [TextTag tagFor:[NSString stringWithString:_currentResult] mono:_mono];
        if (_bold) {
            tag.color = @"#FFFF00";
            tag.bold = YES;
        }
        [_currentResult setString:@""];
        [_currenList addObject:tag];
    }
    
    if ([_currenList count] > 0) {
        NSArray *items = [NSArray arrayWithArray:_currenList];
        block(items);
        [_subject sendNext:items];
        [_currenList removeAllObjects];
    }
}

-(BOOL) isNextNodeNewline:(NSArray *)array index:(NSUInteger)index {
    BOOL isNewLine = NO;
    NSUInteger next = index + 1;
    
    if(next < [array count]) {
        HTMLNode *node = array[next];
        if([[node tagName] isEqualToString:@"text"]){
            NSString *contents = [node rawContents];
            isNewLine = [contents isEqualToString:@"\r\n"];
        }
    }
    
    return isNewLine;
}

- (UInt16) numberFrom: (NSString *)data {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:data];
    return [((NSNumber*)myNumber) unsignedIntValue];
}

-(void) ifNext:(PredicateBlock)filter then:(CompleteBlock)then {
    if(filter(nil)) {
        then(nil);
    }
}

- (void)parseTdp:(NSString *)data {
    
    NSString *pattern = @"TDPs:\\s+(\\d+)";
    NSString *trimmed = [data trimWhitespaceAndNewline];
    
    NSString *ranks = [self replace:trimmed withPattern:pattern andTemplate:@"$1"];
    
    [_gameContext.globalVars setCacheObject:ranks forKey:@"tdp"];
    
    [_exp sendNext:nil];
}

-(void) parseExp:(NSString *)compId withData:(NSString *)data isNew:(BOOL)isNew {
    
    NSString *pattern = @".+:\\s+(\\d+)\\s(\\d+)%\\s(\\w.*)?.*";
    NSString *trimmed = [data trimWhitespaceAndNewline];
    
    NSString *ranks = [self replace:trimmed withPattern:pattern andTemplate:@"$1.$2"];
    NSString *mindState = [self replace:trimmed withPattern:pattern andTemplate:@"$3"];
    LearningRate *learningRate = [LearningRate fromDescription:mindState];
    
    SkillExp *exp = [[SkillExp alloc] init];
    exp.name = [compId substringFromIndex:4];
    exp.mindState = learningRate;
    exp.ranks = [NSDecimalNumber decimalNumberWithString:ranks];
    exp.isNew = isNew;
    
    [_gameContext.globalVars setCacheObject:ranks
                         forKey:[NSString stringWithFormat:@"%@.Ranks", exp.name]];
    [_gameContext.globalVars setCacheObject:[NSString stringWithFormat:@"%hu", exp.mindState.rateId]
                         forKey:[NSString stringWithFormat:@"%@.LearningRate", exp.name]];
    [_gameContext.globalVars setCacheObject:exp.mindState.description
                         forKey:[NSString stringWithFormat:@"%@.LearningRateName", exp.name]];
    
    [_exp sendNext:exp];
}

-(float) floatFromString:(NSString *)data {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    f.positiveFormat = @"0.##";
    NSNumber * number = [f numberFromString:data];
    return [number floatValue];
}

-(NSString *) replace: (NSString *)data withPattern:(NSString *)pattern andTemplate:(NSString *)template {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    return [regex stringByReplacingMatchesInString:data
                                           options:0
                                             range:NSMakeRange(0, [data length])
                                      withTemplate:template];
}

@end
