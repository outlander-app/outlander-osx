//
//  ExpUpdateHandlerTester.swift
//  Outlander
//
//  Created by Joseph McBride on 4/23/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation
import Quick
import Nimble

class ExpUpdateHandlerTester : QuickSpec {
    
    var handler = ExpUpdateHandler()
    let context = GameContext()
    
    var exp = [SkillExp]()
    var settings = [String: String]()

    override func spec() {
        
        handler.emitSetting = { (key,value) in
            self.settings[key] = value
        }
        
        handler.emitExp = { (exp) in
            self.exp.append(exp)
        }
        
        describe("handler") {
            
            beforeEach {
                self.exp = []
                self.settings = [String: String]()
                
                self.handler.handle([], text: ExpUpdateHandler.start_check, context: self.context)
            }
            
            it("handles parsing exp") {
                
                var one = "Shield Usage:    743 59% clear          (0/34)     Light Armor:    773 98% thoughtful          (4/34)"
                var two = "Chain Armor:    689 44% clear          (0/34)      Brigandine:    667 17% clear          (0/34)"
                
                self.handler.handle([], text: one, context: self.context)
                self.handler.handle([], text: two, context: self.context)
                
                expect(self.exp.count).to(equal(4))
                
                expect(self.exp[0].name).to(equal("Shield_Usage"))
                expect(self.exp[0].ranks).to(equal(743.59))
                expect(self.exp[0].mindState).to(equal(LearningRate.fromRate(0)))
                
                expect(self.exp[1].name).to(equal("Light_Armor"))
                expect(self.exp[1].ranks).to(equal(773.98))
                expect(self.exp[1].mindState).to(equal(LearningRate.fromRate(4)))
                
                expect(self.settings["Shield_Usage.Ranks"]).to(equal("743.59"))
                expect(self.settings["Shield_Usage.LearningRate"]).to(equal("0"))
                expect(self.settings["Shield_Usage.LearningRateName"]).to(equal("clear"))
                
                expect(self.settings["Light_Armor.Ranks"]).to(equal("773.98"))
                expect(self.settings["Light_Armor.LearningRate"]).to(equal("4"))
                expect(self.settings["Light_Armor.LearningRateName"]).to(equal("thoughtful"))
            }
        }
    }
}