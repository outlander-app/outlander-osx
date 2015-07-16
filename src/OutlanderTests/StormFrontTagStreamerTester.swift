//
//  StormFrontTagStreamerTester.swift
//  Outlander
//
//  Created by Joseph McBride on 3/21/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa
import Quick
import Nimble

class StormFrontTagStreamerTester: QuickSpec {
    
    let streamer = StormFrontTagStreamer()
    var nodes = [Node]()
    var tags = [TextTag]()
    var exp = [SkillExp]()
    var settings = [String: String]()
    
    override func spec() {
        
        streamer.emitSetting = { (key,value) in
            self.settings[key] = value
        }
        
        streamer.emitExp = { (exp) in
            self.exp.append(exp)
        }
        
        describe("streamer", {
            
            beforeEach({
                self.nodes = []
                self.tags = []
                self.exp = []
                self.settings = [String: String]()
            })
            
            it("excludes extra line breaks") {
                let data = [
                "<clearStream id='inv' ifClosed=''/><pushStream id='inv'/>Your worn items are:",
                "  a divine charm",
                "  a patched hide coat",
                "  some navy goatskin pants",
                "  a dented iron ring",
                "  a canvas miner's backpack",
                "<popStream/>",
                "<dialogData id='minivitals'><skin id='healthSkin' name='healthBar' controls='health' left='0%' top='0%' width='25%' height='100%'/><progressBar id='health' value='100' text='health 100%' left='0%' customText='t' top='0%' width='25%' height='100%'/></dialogData>",
                "<dialogData id='minivitals'><skin id='staminaSkin' name='staminaBar' controls='stamina' left='25%' top='0%' width='25%' height='100%'/><progressBar id='stamina' value='100' text='fatigue 100%' left='25%' customText='t' top='0%' width='25%' height='100%'/></dialogData>",
                "<dialogData id='minivitals'><progressBar id='concentration' value='100' text='concentration 100%' left='75%' customText='t' top='0%' width='25%' height='100%'/></dialogData>",
                "<indicator id='IconBLEEDING' visible='n'/><streamWindow id='room' title='' subtitle='' location='center' target='drop' ifClosed='' resident='true'/>",
                "<clearStream id='room'/>",
                "<pushStream id='room'/>",
                "<compDef id='room desc'/>  <compDef id='room creatures'/><compDef id='room objs'/>",
                "<compDef id='room players'/>",
                "<compDef id='room exits'/>",
                "<compDef id='room extra'/>",
                "<popStream id='room'/>",
                "<nav/>",
                "<streamWindow id='main' title='Story' subtitle=\" - [Wilds, Pine Needle Path]\" location='center' target='drop'/>",
                "<streamWindow id='room' title='Room' subtitle=\" - [Wilds, Pine Needle Path]\" location='center' target='drop' ifClosed='' resident='true'/>",
                "<component id='room desc'>A well-trod path leads from a small open gateway in the town wall and heads into a grove of whispering pine.  Lean, muscular figures stride by briskly, some carrying longbows, others staves, and all garbed in muted tones of earth and forest.</component>",
                "<component id='room objs'>You also see <pushBold/>a journeyman<popBold/>.</component>",
                "<component id='room players'></component>",
                "<component id='room exits'>Obvious paths: <d>north</d>.<compass></compass></component>",
                "<component id='room extra'></component>",
                "<output class=\"mono\"/>",
                ""
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(2))
            }
            
            it("excludes extra line breaks - inv stream") {
                let data = [
                "<clearStream id='inv' ifClosed=''/><pushStream id='inv'/>Your worn items are:",
                "  a divine charm",
                "  a patched hide coat",
                "  some navy goatskin pants",
                "  a dented iron ring",
                "  a canvas miner's backpack",
                "<popStream/>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
            }

            it("streams login tag to arrivals") {
                let data = [
                    "<pushStream id=\"logons\"/> * Arneson joins the adventure.\r\n"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(1))
                expect(self.tags[0].text).to(equal("* Arneson joins the adventure.\n"))
                expect(self.tags[0].targetWindow).to(equal("arrivals"))
            }
            
            it("streams death tag to deaths") {
                let data = [
                    "<pushStream id=\"death\"/> * A fiery phoenix soars into the heavens\r\n"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(1))
                let tag = self.tags[0]
                expect(tag.text).to(equal("* A fiery phoenix soars into the heavens\n"))
                expect(tag.targetWindow).to(equal("deaths"))
            }
            
            it("streams exp into settings") {
                let data = [
                    "<component id='exp Scholarship'>     Scholarship:    4 23% thoughtful   </component>\r\n"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                
                expect(self.settings["Scholarship.Ranks"]).toNot(beNil())
                expect(self.settings["Scholarship.Ranks"]).to(equal("4.23"))
                
                expect(self.settings["Scholarship.LearningRate"]).toNot(beNil())
                expect(self.settings["Scholarship.LearningRate"]).to(equal("4"))
                
                expect(self.settings["Scholarship.LearningRateName"]).toNot(beNil())
                expect(self.settings["Scholarship.LearningRateName"]).to(equal("thoughtful"))
            }
            
            it("streams new exp into settings") {
                let data = [
                    "<component id='exp Athletics'><preset id='whisper'>       Athletics:   50 33% deliberative </preset></component>\r\n"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                
                expect(self.settings["Athletics.Ranks"]).toNot(beNil())
                expect(self.settings["Athletics.Ranks"]).to(equal("50.33"))
                
                expect(self.settings["Athletics.LearningRate"]).toNot(beNil())
                let rate = LearningRate.fromDescription("deliberative")
                expect(self.settings["Athletics.LearningRate"]).to(equal("\(rate.rateId)"))
                
                expect(self.settings["Athletics.LearningRateName"]).toNot(beNil())
                expect(self.settings["Athletics.LearningRateName"]).to(equal("deliberative"))
            }
            
            it("streams new exp into exp") {
                let data = [
                    "<component id='exp Athletics'><preset id='whisper'>       Athletics:   50 33% deliberative </preset></component>\r\n"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.exp.count).to(equal(1))
                
                expect(self.exp[0].name).to(equal("Athletics"))
                expect(self.exp[0].ranks).to(equal(50.33))
                expect(self.exp[0].isNew).to(equal(true))
                expect(self.exp[0].mindState).to(equal(LearningRate.fromDescription("deliberative")))
            }
            
            it("streams exp into exp") {
                let data = [
                    "<component id='exp Athletics'>       Athletics:   50 33% deliberative </component>\r\n"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.exp.count).to(equal(1))
                
                expect(self.exp[0].name).to(equal("Athletics"))
                expect(self.exp[0].ranks).to(equal(50.33))
                expect(self.exp[0].isNew).to(equal(false))
                expect(self.exp[0].mindState).to(equal(LearningRate.fromDescription("deliberative")))
            }
            
            it("streams zero exp into exp") {
                let data = [
                    "<component id='exp Athletics'>       Athletics:   50 33% deliberative </component>\r\n",
                    "<component id='exp Athletics'></component>\r\n"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.exp.count).to(equal(2))
                
                expect(self.exp[1].name).to(equal("Athletics"))
                expect(self.exp[1].ranks).to(equal(0.0))
                expect(self.exp[1].isNew).to(equal(false))
                expect(self.exp[1].mindState).to(equal(LearningRate.fromRate(0)))
            }
            
            it("streams brief exp into exp") {
                let data = [
                    "<component id='exp Shield Usage'><d cmd='skill Shield Usage'>  Shield</d>:   71 33% [33/34]</component>\r\n"
                ]
                
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.exp.count).to(equal(1))
                
                expect(self.exp[0].name).to(equal("Shield_Usage"))
                expect(self.exp[0].ranks).to(equal(71.33))
                expect(self.exp[0].isNew).to(equal(false))
                expect(self.exp[0].mindState).to(equal(LearningRate.fromRate(33)))
            }
            
            it("streams -new- brief exp into exp") {
                let data = [
                    "<component id='exp Scholarship'><preset id='whisper'><d cmd='skill Scholarship'> Scholar</d>:  552 30%  [ 3/34]</preset></component>"
                ]
                
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.exp.count).to(equal(1))
                
                println("ranks: \(self.exp[0].ranks)")
                
                expect(self.exp[0].name).to(equal("Scholarship"))
                expect(self.exp[0].ranks).to(equal(552.30))
                expect(self.exp[0].isNew).to(equal(true))
                expect(self.exp[0].mindState).to(equal(LearningRate.fromRate(3)))
            }
            
            it("streams room exists into settings") {
                let data = [
                    "<component id='room exits'>Obvious paths: <d>north</d>, <d>west</d>, <d>northwest</d>.<compass></compass></component>\r\n",
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.settings.count).to(equal(1))
                
                expect(self.settings["roomexits"]).toNot(beNil())
                expect(self.settings["roomexits"]).to(equal("Obvious paths: north, west, northwest."))
            }
            
            it("streams room objs into settings") {
                let data = [
                    "<component id='room objs'>You also see a rock and <pushBold/>a journeyman<popBold/>.</component>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.settings.count).to(equal(4))
                
                expect(self.settings["roomobjs"]).toNot(beNil())
                expect(self.settings["roomobjs"]).to(equal("You also see a rock and a journeyman."))
            }
            
            it("streams room objs 'original' into settings (for monster bold)") {
                let data = [
                    "<component id='room objs'>You also see a rock and <pushBold/>a journeyman<popBold/>.</component>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.settings.count).to(equal(4))
                
                expect(self.settings["roomobjsorig"]).toNot(beNil())
                expect(self.settings["roomobjsorig"]).to(equal("You also see a rock and <pushbold/>a journeyman<popbold/>."))
            }
            
            it("streams monsterlist/monstercount into settings") {
                let data = [
                    "<component id='room objs'>You also see a rock and <pushBold/>a journeyman<popBold/>.</component>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.settings.count).to(equal(4))
                
                expect(self.settings["monsterlist"]).toNot(beNil())
                expect(self.settings["monsterlist"]).to(equal("a journeyman"))
                
                expect(self.settings["monstercount"]).toNot(beNil())
                expect(self.settings["monstercount"]).to(equal("1"))
            }
            
            it("streams colored room name") {
                let data = [
                    "<style id=\"roomName\" />[The Crossing, Truffenyi Place]"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(1))
                
                expect(self.tags[0].color).to(equal("#0000FF"))
            }
            
            it("streams room exits when none") {
                let data = [
                    "<component id='room exits'>Obvious exits: none.<compass></compass></component>",
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                
                expect(self.settings["roomexits"]).to(equal("Obvious exits: none."))
            }
            
            it("streams room titles with quotes") {
                let data = [
                    "<streamWindow id='main' title='Room' subtitle=\" - [Barana's Shipyard, Receiving Yard]\" location='center' target='drop' ifClosed='' resident='true'/>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                
                expect(self.settings["roomtitle"]).to(equal("[Barana's Shipyard, Receiving Yard]"))
            }
            
            it("streams vitals - health") {
                let data = [
                    "<dialogData id='minivitals'><skin id='healthSkin' name='healthBar' controls='health' left='0%' top='0%' width='25%' height='100%'/><progressBar id='health' value='42' text='health 100%' left='0%' customText='t' top='0%' width='25%' height='100%'/></dialogData>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                
                expect(self.settings["health"]).to(equal("42"))
            }
            
            it("streams vitals - concentration") {
                let data = [
                    "<dialogData id='minivitals'><progressBar id='concentration' value='42' text='concentration 100%' left='75%' customText='t' top='0%' width='25%' height='100%'/></dialogData>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                
                expect(self.settings["concentration"]).to(equal("42"))
            }
            
            it("creates command for d tags") {
                let data = [
                    "<d cmd=\"HELP search stealing\">help search stealing</d>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(1))
                expect(self.tags[0].text).to(equal("help search stealing"))
                expect(self.tags[0].command).to(equal("HELP search stealing"))
            }
            
            it("sets game and charactername settings") {
                let data = [
                    "<app char=\"Arneson\" game=\"DR\" title=\"[DR: Arneson] StormFront\"/>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.settings["charactername"]).to(equal("Arneson"))
                expect(self.settings["game"]).to(equal("DR"))
            }
            
            it("creates whisper tags") {
                let data = [
                    "<pushStream id=\"whispers\"/><preset id=\"whisper\">You whisper to Someone,</preset> \"OOC: It's a secret to everybody.\"",
                    "<popStream/><pushStream id=\"ooc\"/><preset id=\"whisper\">You whisper to Someone,</preset> \"OOC: It's a secret to everybody.\"",
                    "<popStream/><preset id=\"whisper\">You whisper to Someone,</preset> \"OOC: It's a secret to everybody.\""
                ]
              
                self.streamer.isSetup = true
                self.streamData(data)
                
                expect(self.tags.count).to(equal(3))
            }
            
            it("sets hidden ON") {
                let data = [
                    "<indicator id='IconHIDDEN' visible='y'/>You melt into the background, convinced that your attempt to hide went unobserved."
                ]
                
                self.streamer.isSetup = true
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(2))
                expect(self.settings["hidden"]).to(equal("1"))
            }
            
            it("sets hidden OFF") {
                let data = [
                    "<indicator id='IconHIDDEN' visible='n'/>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.settings["hidden"]).to(equal("0"))
            }
            
            it("sets indicator states") {
                let data = [
                    "<indicator id=\"IconKNEELING\" visible=\"n\"/><indicator id=\"IconPRONE\" visible=\"n\"/><indicator id=\"IconSITTING\" visible=\"y\"/><indicator id=\"IconSTANDING\" visible=\"n\"/>You sit up."
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(2))
                expect(self.settings["prone"]).to(equal("0"))
                expect(self.settings["sitting"]).to(equal("1"))
                expect(self.settings["kneeling"]).to(equal("0"))
                expect(self.settings["standing"]).to(equal("0"))
            }
            
            it("sets compass dirs") {
                let data = [
                    "<compass><dir value=\"e\"/><dir value=\"sw\"/><dir value=\"nw\"/></compass>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
                expect(self.settings["north"]).to(equal("0"))
                expect(self.settings["south"]).to(equal("0"))
                expect(self.settings["east"]).to(equal("1"))
                expect(self.settings["west"]).to(equal("0"))
                expect(self.settings["northeast"]).to(equal("0"))
                expect(self.settings["northwest"]).to(equal("1"))
                expect(self.settings["southeast"]).to(equal("0"))
                expect(self.settings["southwest"]).to(equal("1"))
                expect(self.settings["up"]).to(equal("0"))
                expect(self.settings["down"]).to(equal("0"))
                expect(self.settings["out"]).to(equal("0"))
            }
            
            it("can display profile usage") {
                let data = [
                    "Your default:  <pushBold/>nowindow<popBold/>.",
                    "<d><b>PROFILE /EDIT</b></d>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(6))
                expect(self.tags[4].text).to(equal("PROFILE /EDIT"))
            }
            
            it("can display dynastream spells") {
                let data = [
                    "<dynaStream id='spells'>Fae Arts</dynaStream>",
                    "<dynaStream id='spells'>  <d cmd=\"_magic ask -3683 Glythtide's Joy\">Glythtide's Joy</d></dynaStream>",
                    "<dynaStream id='spells'></dynaStream>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(6))
                expect(self.tags[2].text).to(equal("  Glythtide's Joy"))
            }
            
            it("ignores percWindow (for now)") {
                let data = [
                    "<clearStream id=\"percWindow\"/>",
                    "<pushStream id=\"percWindow\"/>Bear Strength<popStream/><pushStream id=\"percWindow\"/>  (Indefinite)",
                    "<popStream/>"
                ]
              
                self.streamData(data)
                
                expect(self.tags.count).to(equal(0))
//                expect(self.tags[0].text).to(equal("bear strength"))
//                expect(self.tags[0].targetWindow).to(equal("percWindow"))
            }
        })
    }
    
    func streamData(data:[String]) {
        let tokenizer = StormFrontTokenizer()
        
        for line in data {
            let tokens = tokenizer.tokenize(line)
            for token in tokens {
                self.nodes.append(token)
            }
        }
        
        self.tags = self.streamer.stream(self.nodes)
    }
}