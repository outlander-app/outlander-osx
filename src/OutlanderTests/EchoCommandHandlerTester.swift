//
//  EchoCommandHandlerTester.swift
//  Outlander
//
//  Created by Joseph McBride on 5/4/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa
import Quick
import Nimble

@objc
class StubCommandRelay : NSObject, CommandRelay {
    
    var echos:[TextTag] = []
    
    func sendCommand(ctx:CommandContext) {
    }
    
    func sendEcho(tag:TextTag) {
        self.echos.append(tag)
    }
}

class EchoCommandHandlerTester: QuickSpec {
    
    override func spec() {
        
        var handler:EchoCommandHandler?
        var relay:StubCommandRelay?
        var context:GameContext?
        
        describe("#echo") {
            
            beforeEach() {
                relay = StubCommandRelay()
                handler = EchoCommandHandler(relay!)
                context = GameContext()
            }
            
            it("can handle #echo") {
                expect(handler?.canHandle("#echo")).to(equal(true))
                expect(handler?.canHandle("#ech")).to(equal(false))
                expect(handler?.canHandle("#something")).to(equal(false))
            }
            
            it("sets target window") {
                handler?.handle("#echo >Log something to log", withContext: context!)
                
                expect(relay?.echos.count).to(equal(1))
                expect(relay?.echos[0].text).to(equal("something to log\n"))
                expect(relay?.echos[0].targetWindow).to(equal("log"))
            }
            
            it("sets foreground color") {
                handler?.handle("#echo #efefef something to log", withContext: context!)
                
                expect(relay?.echos.count).to(equal(1))
                expect(relay?.echos[0].text).to(equal("something to log\n"))
                expect(relay?.echos[0].color).to(equal("#efefef"))
                expect(relay?.echos[0].backgroundColor).to(equal(""))
            }
            
            it("sets background color") {
                handler?.handle("#echo #efefef,#ffffff something to log", withContext: context!)
                
                expect(relay?.echos.count).to(equal(1))
                expect(relay?.echos[0].text).to(equal("something to log\n"))
                expect(relay?.echos[0].color).to(equal("#efefef"))
                expect(relay?.echos[0].backgroundColor).to(equal("#ffffff"))
            }
            
            it("sends echo without options") {
                handler?.handle("#echo something to log", withContext: context!)
                
                expect(relay?.echos.count).to(equal(1))
                expect(relay?.echos[0].text).to(equal("something to log\n"))
                expect(relay?.echos[0].targetWindow).to(equal(""))
            }
        }
    }
}