//
//  GameParserTester.m
//  Outlander
//
//  Created by Joseph McBride on 1/24/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1
#import <Foundation/Foundation.h>
#import <Quick/Quick.h>
#import <Nimble/Nimble-Swift.h>
#import <Nimble/Nimble.h>

#import "GameParser.h"
#import "TextTag.h"
#import "Vitals.h"
#import "SkillExp.h"
#import "Roundtime.h"
#import "Outlander-Swift.h"

QuickSpecBegin(GameParserSpec)

describe(@"GameParser", ^{
   
    __block GameParser *_parser = nil;
    __block GameContext *_context = nil;
    
    beforeEach(^{
        _context = [GameContext newInstance];
        _parser = [[GameParser alloc] initWithContext:_context];
    });
    
    context(@"parse", ^{
        
        it(@"should parse prompt", ^{
            NSString *prompt = @"<prompt time=\"1390623788\">&gt;</prompt>";
            
            __block TextTag *result = nil;
            
            [_parser parse:prompt then:^(NSArray* res) {
                result = res[0];
            }];

            expect(result.text).to(equal(@">"));
        });
        
        it(@"should parse room name", ^{
            NSString *data = @"<resource picture=\"0\"/><style id=\"roomName\" />[Woodland Path, Brook]";
            
            __block TextTag *result = nil;
            
            [_parser parse:data then:^(NSArray* res) {
                result = res[0];
            }];

            expect(result.text).to(equal(@"[Woodland Path, Brook]"));
            expect(result.color).to(equal(@"#0000FF"));
        });

        it(@"should parse room description", ^{
            NSString *data = @"<style id=\"\"/><preset id='roomDesc'>This shallow stream would probably only come chest-high on a short Halfling.  The water moves lazily southward, but the shifting, sharp rocky floor makes crossing uncomfortable.</preset>  \r\n";
            
            __block TextTag *result = nil;
            
            [_parser parse:data then:^(NSArray* res) {
                result = res[0];
            }];
            
            expect(result.text).to(equal(@"This shallow stream would probably only come chest-high on a short Halfling.  The water moves lazily southward, but the shifting, sharp rocky floor makes crossing uncomfortable.  \r\n"));
        });
        
        it(@"should handle exp mono", ^{
            NSString *data = @"<--><output class=\"mono\"/>\r\n"
            "<-->\r\n"
            "<-->Circle: 8\r\n"
            "<-->Showing all skills with field experience.\r\n"
            "<-->\r\n"
            "<-->          SKILL: Rank/Percent towards next rank/Amount learning/Mindstate Fraction\r\n"
            "<-->      Attunement:     61 11% perusing       (2/34)       Athletics:     51 39% thinking       (5/34)\r\n"
            "<-->\r\n"
            "<-->Total Ranks Displayed: 112\r\n"
            "<-->Time Development Points: 62  Favors: 4  Deaths: 0  Departs: 0\r\n"
            "<-->Overall state of mind: clear\r\n"
            "<-->EXP HELP for more information\r\n"
            "<--><output class=\"\"/>\r\n";
            
            NSArray *lines = [data componentsSeparatedByString:@"<-->"];
            
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            for(NSString *line in lines) {
                [_parser parse:[line stringByReplacingOccurrencesOfString:@"<-->" withString:@""] then:^(NSArray* res) {
                    [results addObjectsFromArray:res];
                    NSLog(@"%@", res);
                }];
            }

            expect(results).to(haveCount(@13));

            TextTag *tag = results[1];
            expect(@(tag.mono)).to(beTrue());

            tag = results[5];
            expect(tag.text).to(equal(@"SKILL: Rank/Percent towards next rank/Amount learning/Mindstate Fraction\r\n"));
        });
        
        it(@"should ignore component tag newline", ^{
            NSString *data = @"<component id='room objs'></component>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];

            expect(results).to(haveCount(@0));
        });
        
        it(@"should ignore compdef tag newline", ^{
            NSString *data = @"<compDef id='exp Shield Usage'></compDef>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];

            expect(results).to(haveCount(@0));
        });
        
        it(@"should ignore dialogdata tag newline", ^{
            NSString *data = @"<dialogData id='minivitals'><skin id='manaSkin' name='manaBar' controls='mana' left='20%' top='0%' width='20%' height='100%'/><progressBar id='mana' value='100' text='mana 100%' left='20%' customText='t' top='0%' width='20%' height='100%'/></dialogData>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];
            
            expect(results).to(haveCount(@0));
        });
        
        it(@"should ignore streamwindow tag newline", ^{
            NSString *data = @"<streamWindow id='main' title='Story' subtitle=\" - [Woodland Path, Brook]\" location='center' target='drop'/>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];
            
            expect(results).to(haveCount(@0));
        });
        
        it(@"should ignore nav tag newline", ^{
            NSString *data = @"<nav/>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];

            expect(results).to(haveCount(@0));
        });
        
        it(@"should ignore opendialog tag newline", ^{
            NSString *data = @"<openDialog id='quick-blank' location='quickBar' title='Blank'><dialogData id='quick-blank' clear='true'></dialogData></openDialog>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];

            expect(results).to(haveCount(@0));
        });
        
        it(@"should ignore switchquickbar tag newline", ^{
            NSString *data = @"<switchQuickBar id='quick-simu'/>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];
            
            expect(results).to(haveCount(@0));
        });
        
        it(@"should ignore indicator tag newline", ^{
            NSString *data = @"<indicator id=\"IconKNEELING\" visible=\"n\"/><indicator id=\"IconPRONE\" visible=\"n\"/><indicator id=\"IconSITTING\" visible=\"n\"/><indicator id=\"IconSTANDING\" visible=\"y\"/><indicator id=\"IconSTUNNED\" visible=\"n\"/><indicator id=\"IconHIDDEN\" visible=\"n\"/><indicator id=\"IconINVISIBLE\" visible=\"n\"/><indicator id=\"IconDEAD\" visible=\"n\"/><indicator id=\"IconWEBBED\" visible=\"n\"/><indicator id=\"IconJOINED\" visible=\"n\"/>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];
            
            expect(results).to(haveCount(@0));
        });
        
        it(@"should color monsterbold", ^{
            NSString *data = @"<preset id='roomDesc'>For a moment you lose your sense of direction.  Bending down to gain a better perspective of the lie of the land, you manage to identify several landmarks and reorient yourself.</preset>  You also see <pushBold/>a musk hog<popBold/>, <pushBold/>a musk hog<popBold/> and <pushBold/>a musk hog<popBold/>.";
            
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];

            expect(results).to(haveCount(@7));
        });
        
        it(@"should set roomdesc global var", ^{
            NSString *data = @"<preset id='roomDesc'>For a moment you lose your sense of direction.  Bending down to gain a better perspective of the lie of the land, you manage to identify several landmarks and reorient yourself.</preset>  You also see <pushBold/>a musk hog<popBold/>, <pushBold/>a musk hog<popBold/> and <pushBold/>a musk hog<popBold/>.";
            
            [_parser parse:data then:^(NSArray* res) {
            }];

            expect(@([_context.globalVars hasKey:@"roomdesc"])).to(beTrue());

            NSString *roomDesc = [_context.globalVars get:@"roomdesc"];
            expect(roomDesc).to(equal(@"For a moment you lose your sense of direction.  Bending down to gain a better perspective of the lie of the land, you manage to identify several landmarks and reorient yourself."));
        });

        it(@"should set roomobjs global var", ^{
            NSString *data = @"<component id='room objs'>You also see a two auroch caravan with several things on it.</component>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];

            expect(results).to(haveCount(0));

            expect(@([_context.globalVars hasKey:@"roomobjs"])).to(beTrue());
            
            NSString *roomObjs = [_context.globalVars get:@"roomobjs"];
            expect(roomObjs).to(equal(@"You also see a two auroch caravan with several things on it."));
        });
        
        it(@"should set spell global var", ^{
            NSString *data = @"<spell>None</spell>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];

            expect(results).to(haveCount(0));
            
            expect(@([_context.globalVars hasKey:@"preparedspell"])).to(beTrue());
            
            NSString *roomObjs = [_context.globalVars get:@"preparedspell"];
            expect(roomObjs).to(equal(@"None"));
        });

        it(@"should set left global var", ^{
            NSString *data = @"<left exist=\"41807070\" noun=\"longsword\">longsword</left>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];
            
            expect(results).to(haveCount(0));

            expect(@([_context.globalVars hasKey:@"lefthand"])).to(beTrue());

            expect([_context.globalVars get:@"lefthand"]).to(equal(@"longsword"));
            expect([_context.globalVars get:@"lefthandid"]).to(equal(@"41807070"));
            expect([_context.globalVars get:@"lefthandnoun"]).to(equal(@"longsword"));
        });
        
        it(@"should set left global var as Empty", ^{
            NSString *data = @"<left>Empty</left>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];
            
            expect(results).to(haveCount(0));

            expect(@([_context.globalVars hasKey:@"lefthand"])).to(beTrue());
            expect(@([_context.globalVars hasKey:@"lefthandid"])).to(beTrue());
            expect(@([_context.globalVars hasKey:@"lefthandnoun"])).to(beTrue());

            expect([_context.globalVars get:@"lefthand"]).to(equal(@"Empty"));
            expect([_context.globalVars get:@"lefthandid"]).to(beNil());
            expect([_context.globalVars get:@"lefthandnoun"]).to(beNil());
        });
        
        it(@"should set right global var", ^{
            NSString *data = @"<right exist=\"41807070\" noun=\"longsword\">longsword</right>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];

            expect(results).to(haveCount(0));

            expect(@([_context.globalVars hasKey:@"righthand"])).to(beTrue());
            expect(@([_context.globalVars hasKey:@"righthandid"])).to(beTrue());
            expect(@([_context.globalVars hasKey:@"righthandnoun"])).to(beTrue());

            expect([_context.globalVars get:@"righthand"]).to(equal(@"longsword"));
            expect([_context.globalVars get:@"righthandid"]).to(equal(@"41807070"));
            expect([_context.globalVars get:@"righthandnoun"]).to(equal(@"longsword"));
        });
        
        it(@"should set right global var as Empty", ^{
            NSString *data = @"<right>Empty</right>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];

            expect(results).to(haveCount(0));

            expect(@([_context.globalVars hasKey:@"righthand"])).to(beTrue());
            expect(@([_context.globalVars hasKey:@"righthandid"])).to(beTrue());
            expect(@([_context.globalVars hasKey:@"righthandnoun"])).to(beTrue());

            expect([_context.globalVars get:@"righthand"]).to(equal(@"Empty"));
            expect([_context.globalVars get:@"righthandid"]).to(beNil());
            expect([_context.globalVars get:@"righthandnoun"]).to(beNil());
        });
        
        it(@"should signal arrivals", ^{
            NSString *data = @"<pushStream id=\"logons\"/> * Tayek joins the adventure.\r\n<popStream/>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.arrivals subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];

            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));
            
            TextTag *tag = signalResults[0];
            
            expect(tag.text).to(equal(@" * Tayek joins the adventure."));
        });
        
        it(@"should signal deaths", ^{
            NSString *data = @"<pushStream id=\"death\"/> * Tayek was just struck down!\r\n<popStream/>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.deaths subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];

            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));
            
            TextTag *tag = signalResults[0];
            
            expect(tag.text).to(equal(@" * Tayek was just struck down!"));
        });
        
        it(@"should signal thoughts", ^{
            NSString *data = @"<pushStream id=\"thoughts\"/><preset id='thought'>You hear your mental voice echo, </preset>\"Testing, one, two.\"\n<popStream/>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.thoughts subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));

            TextTag *tag = signalResults[0];
            
            expect(tag.text).to(equal(@"You hear your mental voice echo, \"Testing, one, two.\""));
        });
        
        it(@"should signal chatter", ^{
            NSString *data = @"<pushStream id=\"chatter\"/><preset id='thought'>Chatter[Mentor Isharon]</preset> Effects of charisma (detailed list):\n<popStream/>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.chatter subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));

            TextTag *tag = signalResults[0];
            
            expect(tag.text).to(equal(@"Chatter[Mentor Isharon]: Effects of charisma (detailed list):"));
        });
        
        it(@"should set roomtitle component", ^{
            NSString *data = @"<streamWindow id='room' title='Room' subtitle=\" - [Ranger Guild, Longhouse]\" location='center' target='drop' ifClosed='' resident='true'/>\r\n";
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];
            
            expect(results).to(haveCount(0));

            expect([_context.globalVars get:@"roomtitle"]).to(equal(@"[Ranger Guild, Longhouse]"));
        });
        
        it(@"should signal concentration vitals", ^{
            NSString *data = @"<dialogData id='minivitals'><progressBar id='concentration' value='98' text='concentration 98%' left='80%' customText='t' top='0%' width='20%' height='100%'/></dialogData>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.vitals subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));

            Vitals *tag = signalResults[0];
            
            expect(tag.name).to(equal(@"concentration"));
            expect(@(tag.value)).to(equal(@(98)));
            
            expect([_context.globalVars get:@"concentration"]).to(equal(@"98"));
        });
        
        it(@"should signal health vitals", ^{
            NSString *data = @"<dialogData id='minivitals'><progressBar id='health' value='98' text='health 98%' left='80%' customText='t' top='0%' width='20%' height='100%'/></dialogData>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.vitals subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));

            Vitals *tag = signalResults[0];
            
            expect(tag.name).to(equal(@"health"));
            expect(@(tag.value)).to(equal(@(98)));
            
            expect([_context.globalVars get:@"health"]).to(equal(@"98"));
        });
        
        it(@"should set exp global variables", ^{
            NSString *data = @"<component id='exp Athletics'><preset id='whisper'>       Athletics:   50 33% deliberative </preset></component>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            
            NSString *ranks = [_context.globalVars get:@"Athletics.Ranks"];
            NSString *learningRate = [_context.globalVars get:@"Athletics.LearningRate"];
            NSString *learningRateName = [_context.globalVars get:@"Athletics.LearningRateName"];

            expect(ranks).toNot(beNil());
            expect(learningRate).toNot(beNil());
            expect(learningRateName).toNot(beNil());

            expect(ranks).to(equal(@"50.33"));
            expect(learningRate).to(equal(@"11"));
            expect(learningRateName).to(equal(@"deliberative"));
        });
        
        it(@"should set exp global variables, not new", ^{
            NSString *data = @"<component id='exp Life Magic'>       Life Magic:   50 33% deliberative </component>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];

            expect(parseResults).to(haveCount(0));
            
            NSString *ranks = [_context.globalVars get:@"Life_Magic.Ranks"];
            NSString *learningRate = [_context.globalVars get:@"Life_Magic.LearningRate"];
            NSString *learningRateName = [_context.globalVars get:@"Life_Magic.LearningRateName"];
            
            expect(ranks).toNot(beNil());
            expect(learningRate).toNot(beNil());
            expect(learningRateName).toNot(beNil());

            expect(ranks).to(equal(@"50.33"));
            expect(learningRate).to(equal(@"11"));
            expect(learningRateName).to(equal(@"deliberative"));
        });
        
        it(@"should signal exp", ^{
            NSString *data = @"<component id='exp Athletics'><preset id='whisper'>       Athletics:   50 33% deliberative </preset></component>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.exp subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];

            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));

            SkillExp *tag = signalResults[0];

            expect(tag.name).to(equal(@"Athletics"));
            expect(tag.ranks).to(equal([NSDecimalNumber decimalNumberWithString:@"50.33"]));
            expect(tag.mindState).to(equal([LearningRate fromDescription:@"deliberative"]));
            expect(@(tag.isNew)).to(beTrue());
        });
        
        it(@"should signal exp, not new", ^{
            NSString *data = @"<component id='exp Athletics'>       Athletics:   150 47% mind lock </component>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.exp subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));

            SkillExp *tag = signalResults[0];

            expect(tag.name).to(equal(@"Athletics"));
            expect(tag.ranks).to(equal([NSDecimalNumber decimalNumberWithString:@"150.47"]));
            expect(tag.mindState).to(equal([LearningRate fromDescription:@"mind lock"]));
            expect(@(tag.isNew)).to(beFalse());
        });
        
        it(@"should signal roundtime", ^{
            NSString *data = @"<roundTime value='1400357815'/>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.roundtime subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));

            Roundtime *tag = signalResults[0];
            
            expect(tag.time).to(equal([NSDate dateWithTimeIntervalSince1970:[@"1400357815" doubleValue]]));
        });
        
        it(@"should handle combat hit messages", ^{
            NSString *data = @"&lt; Moving like a striking snake, you draw a longsword at a musk hog.  A musk hog fails to dodge, mis-stepping and blundering into the blow.  <pushBold/>The longsword lands a heavy strike to the hog's right arm.<popBold/>\r\n";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];

            expect(parseResults).to(haveCount(@3));

            TextTag *tag = parseResults[0];
            expect(tag.text).to(equal(@"< Moving like a striking snake, you draw a longsword at a musk hog.  A musk hog fails to dodge, mis-stepping and blundering into the blow.  "));
            
            tag = parseResults[1];
            expect(tag.text).to(equal(@"The longsword lands a heavy strike to the hog's right arm."));
            
            tag = parseResults[2];
            expect(tag.text).to(equal(@"\r\n"));
        });
        
        it(@"should handle combat non-hit messages", ^{
            NSString *data = @"&lt; You punch your chain-clad fist at a scavenger goblin.  A scavenger goblin turns aside little of the fist with a mace.  \r\n";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];

            expect(parseResults).to(haveCount(@1));

            TextTag *tag = parseResults[0];
            expect(tag.text).to(equal(@"< You punch your chain-clad fist at a scavenger goblin.  A scavenger goblin turns aside little of the fist with a mace.  \r\n"));
        });
        
        it(@"should handle combat monster hit messages", ^{
            NSString *data = @"* Timing it well, a spotted scavenger goblin sweeps low at you.  You fail to evade.  <pushBold/>The cudgel lands a harmless strike to your chest.<popBold/>\r\n";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];

            expect(parseResults).to(haveCount(@3));

            TextTag *tag = parseResults[0];
            expect(tag.text).to(equal(@"* Timing it well, a spotted scavenger goblin sweeps low at you.  You fail to evade.  "));
            
            tag = parseResults[1];
            expect(tag.text).to(equal(@"The cudgel lands a harmless strike to your chest."));
            
            tag = parseResults[2];
            expect(tag.text).to(equal(@"\r\n"));
        });
        
        it(@"should signal exp when tdp", ^{
            NSString *data = @"<component id='exp tdp'>            TDPs:  197</component>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block BOOL signaled = NO;
            
            [_parser.exp subscribeNext:^(id x) {
                signaled = YES;
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            expect(@(signaled)).to(beTrue());

            expect([_context.globalVars get:@"tdp"]).to(equal(@"197"));
        });
        
        it(@"should parse app data", ^{
            NSString *data = @"<app char=\"Tayek\" game=\"DR\" title=\"[DR: Tayek] StormFront\"/>";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];

            expect(parseResults).to(haveCount(0));

            expect([_context.globalVars get:@"charactername"]).to(equal(@"Tayek"));
            expect([_context.globalVars get:@"game"]).to(equal(@"DR"));
        });
        
        it(@"should add newline before 'you also see'", ^{
            NSString *data = @"<preset id='roomDesc'>For a moment you lose your sense of direction.</preset>  You also see <pushBold/>a musk hog<popBold/>, <pushBold/>a musk hog<popBold/> and <pushBold/>a musk hog<popBold/>.";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];

            expect(parseResults).to(haveCount(@7));

            TextTag *tag = parseResults[0];
            expect(tag.text).to(equal(@"For a moment you lose your sense of direction.\nYou also see "));
        });
        
        it(@"should not send talk stream data", ^{
            NSString *data = @"<pushStream id=\"talk\"/><preset id='speech'>You say</preset>, \"Hrm.\"\r\n<popStream/><preset id='speech'>You say</preset>, \"Hrm.\"\r\n";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];

            expect(parseResults).to(haveCount(@1));

            TextTag *tag = parseResults[0];
            expect(tag.text).to(equal(@"You say, \"Hrm.\"\r\n"));
        });
        
        it(@"should send yells", ^{
            NSString *data = @"<pushStream id=\"talk\"/><b>You yell,</b> \"Hogs!\"\r\n<popStream/><b>You yell,</b> \"Hogs!\"\r\n";
            
            __block NSMutableArray *results = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [results addObjectsFromArray:res];
            }];
            
            expect(results).to(haveCount(@1));
            
            TextTag *tag = results[0];
            expect(tag.text).to(equal(@"You yell, \"Hogs!\"\r\n"));
        });
        
        it(@"should signal kneeling indicator", ^{
            NSString *data = @"<indicator id=\"IconKNEELING\" visible=\"y\"/>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.indicators subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));
            
            PlayerStatusIndicator *tag = signalResults[0];
            expect(tag.name).to(equal(@"kneeling"));
            expect(tag.value).to(equal(@"1"));
            
            expect([_context.globalVars get:@"kneeling"]).to(equal(@"1"));
        });
        
        it(@"should signal dead indicator", ^{
            NSString *data = @"<indicator id=\"IconDEAD\" visible=\"n\"/>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.indicators subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));
            
            PlayerStatusIndicator *tag = signalResults[0];
            expect(tag.name).to(equal(@"dead"));
            expect(tag.value).to(equal(@"0"));
            
            expect([_context.globalVars get:@"dead"]).to(equal(@"0"));
        });
        
        it(@"should add directional values", ^{
            NSString *data = @"<compass><dir value=\"e\"/><dir value=\"w\"/></compass>\r\n";
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            __block NSMutableArray *signalResults = [[NSMutableArray alloc] init];
            
            [_parser.directions subscribeNext:^(id x) {
                [signalResults addObject:x];
            }];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));
            expect(signalResults).to(haveCount(@1));

            expect([_context.globalVars get:@"north"]).to(equal(@"0"));
            expect([_context.globalVars get:@"south"]).to(equal(@"0"));
            expect([_context.globalVars get:@"east"]).to(equal(@"1"));
            expect([_context.globalVars get:@"west"]).to(equal(@"1"));
            expect([_context.globalVars get:@"northeast"]).to(equal(@"0"));
            expect([_context.globalVars get:@"northwest"]).to(equal(@"0"));
            expect([_context.globalVars get:@"southeast"]).to(equal(@"0"));
            expect([_context.globalVars get:@"southwest"]).to(equal(@"0"));
            expect([_context.globalVars get:@"up"]).to(equal(@"0"));
            expect([_context.globalVars get:@"down"]).to(equal(@"0"));
            expect([_context.globalVars get:@"out"]).to(equal(@"0"));
        });
        
        it(@"sets monstercount and monsterlist global vars", ^{
           NSString *data = @"<component id='room objs'>You also see <pushBold/>a musk hog<popBold/> and <pushBold/>a musk hog<popBold/>.</component>";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));

            expect([_context.globalVars get:@"monstercount"]).to(equal(@"2"));
            expect([_context.globalVars get:@"monsterlist"]).to(equal(@"a musk hog,a musk hog"));
        });
        
        it(@"sets roomobjorig global vars", ^{
           NSString *data = @"<component id='room objs'>You also see <pushBold/>a musk hog<popBold/> and <pushBold/>a musk hog<popBold/>.</component>";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));

            expect([_context.globalVars get:@"roomobjsorig"]).to(equal(@"You also see <pushbold></pushbold>a musk hog<popbold></popbold> and <pushbold></pushbold>a musk hog<popbold></popbold>."));
        });
        
        it(@"sets roomexits global var", ^{
           NSString *data = @"<component id='room exits'>Obvious paths: <d>north</d>, <d>west</d>, <d>northwest</d>.";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(0));

            expect([_context.globalVars get:@"roomexits"]).to(equal(@"Obvious paths: north, west, northwest."));
        });
        
        it(@"parses <d/> items", ^{
           NSString *data = @"1) <d cmd='choose 1'>blue</d>              2) <d cmd='choose 2'>gold</d>              3) <d cmd='choose 3'>crystal blue</d>";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(@1));
            TextTag *tag = parseResults[0];
            expect(tag.text).to(equal(@"1) blue              2) gold              3) crystal blue"));
        });
        
        it(@"parses direction help <d/> items", ^{
           NSString *data = @"Directions towards Barana's Shipyard: <d cmd=\"North\">North</d>.";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(@1));
            TextTag *tag = parseResults[0];
            expect(tag.text).to(equal(@"Directions towards Barana's Shipyard: North."));
        });

        it(@"parses direction help <d/> items", ^{
           NSString *data = @"Directions towards Barana's Shipyard: <d cmd=\"North\">North</d>.";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(@1));
            TextTag *tag = parseResults[0];
            expect(tag.text).to(equal(@"Directions towards Barana's Shipyard: North."));
        });
        
        it(@"parses <d/> with multiple attributes", ^{
           NSString *data = @"[You can use <d cmd='dir mentors' annotate='15'>DIR MENTORS</d> for directions to get there!]";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(@1));
            TextTag *tag = parseResults[0];
            expect(tag.text).to(equal(@"[You can use DIR MENTORS for directions to get there!]"));
        });
        
        it(@"parses hyperlinks", ^{
           NSString *data = @"<a href='https://store.play.net/store/purchase/dr'>Simucoin Store</a>";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(@1));
            TextTag *tag = parseResults[0];
            expect(tag.text).to(equal(@"Simucoin Store"));
            expect(tag.href).to(equal(@"https://store.play.net/store/purchase/dr"));
        });
        
        it(@"keeps whitespace with hyperlinks", ^{
           NSString *data = @"                       <a href='http://www.topmudsites.com/vote-DragonRealms.html'>Visit Top Mud Sites!</a>";
            
            __block NSMutableArray *parseResults = [[NSMutableArray alloc] init];
            
            [_parser parse:data then:^(NSArray* res) {
                [parseResults addObjectsFromArray:res];
            }];
            
            expect(parseResults).to(haveCount(@2));
            
            TextTag *whitespace = parseResults[0];
            expect(whitespace.text).to(equal(@"                       "));
            
            TextTag *tag = parseResults[1];
            expect(tag.text).to(equal(@"Visit Top Mud Sites!"));
            expect(tag.href).to(equal(@"http://www.topmudsites.com/vote-DragonRealms.html"));
        });
    });
});

QuickSpecEnd
