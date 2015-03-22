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
    
    override func spec() {
        
        describe("streamer", {
            
            it("excludes extra line breaks", {
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
               
                var nodes = [Node]()
                let tokenizer = StormFrontTokenizer()
                
                for line in data {
                    tokenizer.tokenize(line, tokenReceiver: { (node:Node) -> (Bool) in
                       nodes.append(node)
                        return true
                    })
                }
                let streamer = StormFrontTagStreamer()
                let result = streamer.stream(nodes)
                
                expect(result.count).to(equal(2))
            })
            
            it("excludes extra line breaks - inv stream", {
                let data = [
                "<clearStream id='inv' ifClosed=''/><pushStream id='inv'/>Your worn items are:",
                "  a divine charm",
                "  a patched hide coat",
                "  some navy goatskin pants",
                "  a dented iron ring",
                "  a canvas miner's backpack",
                "<popStream/>"
                ]
               
                var nodes = [Node]()
                let tokenizer = StormFrontTokenizer()
                
                for line in data {
                    tokenizer.tokenize(line, tokenReceiver: { (node:Node) -> (Bool) in
                       nodes.append(node)
                        return true
                    })
                }
                let streamer = StormFrontTagStreamer()
                let result = streamer.stream(nodes)
                
                expect(result.count).to(equal(0))
            })
        })
    }
}