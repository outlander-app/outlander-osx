//
//  ParserTests.swift
//  ParserTests
//
//  Created by Joseph McBride on 3/19/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Cocoa
import Quick
import Nimble

class StormFrontTokenizerTester: QuickSpec {
    
    override func spec() {
        describe("tokenizer", {
            
            it("tokenizes tag with attributes") {
                let tokenizer = StormFrontTokenizer()
                let data = "<prompt time=\"1390623788\">&gt;</prompt>"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(2))
                expect(results[0].name).to(equal("prompt"))
                expect(results[0].value).to(equal("&gt;"))
                expect(results[0].hasAttr("time")).to(equal(true))
                expect(results[0].attr("time")).to(equal("1390623788"))
            }
            
            it("tokenizes tag with single-tic attributes") {
                let tokenizer = StormFrontTokenizer()
                let data = "<d cmd='choose 1'>blue</d>"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(2))
                expect(results[0].name).to(equal("d"))
                expect(results[0].value).to(equal("blue"))
                expect(results[0].hasAttr("cmd")).to(equal(true))
                expect(results[0].attr("cmd")).to(equal("choose 1"))
            }
            
            it("tokenizes tag without attributes") {
                let tokenizer = StormFrontTokenizer()
                let data = "<prompt>value</prompt>"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(2))
                expect(results[0].name).to(equal("prompt"))
                expect(results[0].value).to(equal("value"))
            }
            
            it("tokenizes text and tag") {
                let tokenizer = StormFrontTokenizer()
                let data = " 1) <d cmd='choose 1'>blue</d>"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(3))
                
                expect(results[0].name).to(equal("text"))
                expect(results[0].value).to(equal(" 1) "))
                
                expect(results[1].name).to(equal("d"))
                expect(results[1].value).to(equal("blue"))
            }
            
            it("tokenizes multiple tags") {
                let tokenizer = StormFrontTokenizer()
                let data = " 1) <d cmd='choose 1'>blue</d>              2) <d cmd='choose 2'>gold</d>"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(5))
                
                expect(results[0].name).to(equal("text"))
                expect(results[0].value).to(equal(" 1) "))
                
                expect(results[1].name).to(equal("d"))
                expect(results[1].value).to(equal("blue"))
                
                expect(results[2].name).to(equal("text"))
                expect(results[2].value).to(equal("              2) "))
                
                expect(results[3].name).to(equal("d"))
                expect(results[3].value).to(equal("gold"))
            }
            
            it("tokenizes self closing tags") {
                let tokenizer = StormFrontTokenizer()
                let data = "<pushBold/>a journeyman<popBold/>"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(4))
                
                expect(results[0].name).to(equal("pushbold"))
                expect(results[1].name).to(equal("text"))
                expect(results[2].name).to(equal("popbold"))
            }
            
            it("tokenizes self closing tag with attributes") {
                let tokenizer = StormFrontTokenizer()
                let data = "<pushStream id=\"logons\"/> * Arneson joins the adventure."
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(3))
                
                expect(results[0].name).to(equal("pushstream"))
                expect(results[0].hasAttr("id")).to(equal(true))
                expect(results[0].attr("id")).to(equal("logons"))
            }
            
            it("tokenizes attributes with slashes") {
                let tokenizer = StormFrontTokenizer()
                let data = "<link id='1' value='Game Info' cmd='url:/dr/info/' />"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(2))
                
                let result = results[0]
                
                expect(result.name).to(equal("link"))
                expect(result.attr("id")).to(equal("1"))
                expect(result.attr("cmd")).to(equal("url:/dr/info/"))
            }
            
            it("tokenizes compass directions") {
                let tokenizer = StormFrontTokenizer()
                let data = "<compass><dir value=\"e\"/><dir value=\"w\"/></compass>\r\n"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(2))
                
                expect(results[0].children.count).to(equal(2))
                
                expect(results[0].children[0].name).to(equal("dir"))
                expect(results[0].children[0].attr("value")).to(equal("e"))
                
                expect(results[0].children[1].name).to(equal("dir"))
                expect(results[0].children[1].attr("value")).to(equal("w"))
            }
            
            it("tokenizes compass + prompt") {
                let tokenizer = StormFrontTokenizer()
                let data = "<compass><dir value=\"n\"/></compass><prompt time=\"1426818091\">&gt;</prompt>\r\n"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(3))
                
                expect(results[0].children.count).to(equal(1))
                
                expect(results[0].children[0].name).to(equal("dir"))
                expect(results[0].children[0].attr("value")).to(equal("n"))
            
                expect(results[1].name).to(equal("prompt"))
            }
            
            it("tokenizes element with attributes and children") {
                let tokenizer = StormFrontTokenizer()
                let data = "<compass id='test'><dir value=\"e\"/><dir value=\"w\"/></compass>\r\n"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(2))
                
                expect(results[0].hasAttr("id")).to(equal(true))
                
                expect(results[0].children.count).to(equal(2))
                
                expect(results[0].children[0].name).to(equal("dir"))
                expect(results[0].children[0].attr("value")).to(equal("e"))
                
                expect(results[0].children[1].name).to(equal("dir"))
                expect(results[0].children[1].attr("value")).to(equal("w"))
            }
            
            it("tokenizes crazy openDialog") {
                let tokenizer = StormFrontTokenizer()
                let data = "<openDialog id='quick-simu' location='quickBar' title='Information'><dialogData id='quick-simu' clear='true'><link id='1' value='Game Info' cmd='url:/dr/info/' /><link id='2' value='Calendar' cmd='url:/bounce/redirect.asp?URL=http://forums.play.net/calendar?game=dragonrealms' /><link id='3' value='Forums' cmd='bbs' echo='bbs' /><link id='4' value='News' cmd='news' echo='news' /><link id='5' value='Policy' cmd='policy' echo='policy' /><link id='6' value='Premium' cmd='url:/dr/premium/' /><link id='7' value='Platinum' cmd='url:/dr/platinum/' /><link id='8' value='SimuCon' cmd='url:/bounce/redirect.asp?URL=http://www.simucon.com' /><link id='9' value='Box Office' cmd='url:/dr/boxoffice.asp' /><link id='10' value='Vote for DR!' cmd='url:/bounce/redirect.asp?URL=http://www.topmudsites.com/vote-DragonRealms.html' /><link id='11' value='Elanthipedia' cmd='url:/bounce/redirect.asp?URL=https://elanthipedia.play.net/mediawiki/index.php/Main_Page' /><link id='12' value='Simucoins Store' cmd='url:/bounce/redirect.asp?URL=https://store.play.net/store/purchase/dr' /></dialogData></openDialog>"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(2))
                
                expect(results[0].name).to(equal("opendialog"))
                expect(results[0].attr("title")).to(equal("Information"))
                
                expect(results[0].children.first!.name).to(equal("dialogdata"))
                expect(results[0].children.first!.attr("id")).to(equal("quick-simu"))
                expect(results[0].children.first!.children.count).to(equal(12))
                
                let links = results[0].children.first!.children
                
                expect(links[0].name).to(equal("link"))
                expect(links[0].attr("value")).to(equal("Game Info"))
                expect(links[0].attr("cmd")).to(equal("url:/dr/info/"))
            }
            
            it("tokenizes plain text and newlines") {
                let tokenizer = StormFrontTokenizer()
                let data = "   Last login :  Tuesday, March 17, 2015 at 00:51:53\r\n"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(2))
                expect(results[0].value).to(equal("   Last login :  Tuesday, March 17, 2015 at 00:51:53"))
                expect(results[1].name).to(equal("eot"))
            }
            
            it("tokenizes pushStream") {
                let tokenizer = StormFrontTokenizer()
                let data = "<pushStream id=\"logons\"/> * Arneson joins the adventure.\r\n"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(3))
                
                expect(results[0].name).to(equal("pushstream"))
                expect(results[0].attr("id")).to(equal("logons"))
                
                expect(results[1].name).to(equal("text"))
                expect(results[1].value).to(equal(" * Arneson joins the adventure."))
                
                expect(results[2].name).to(equal("eot"))
            }
            
            it("tokenizes roomDesc") {
                let tokenizer = StormFrontTokenizer()
                let data = "<style id=\"\"/><preset id='roomDesc'>A well-trod path leads from a small open gateway in the town wall and heads into a grove of whispering pine.  Lean, muscular figures stride by briskly, some carrying longbows, others staves, and all garbed in muted tones of earth and forest.</preset>  You also see <pushBold/>a journeyman<popBold/>.\r\n"
                
                let results = tokenizer.tokenize(data);
                
                expect(results.count).to(equal(8))
            }
        })
    }
}