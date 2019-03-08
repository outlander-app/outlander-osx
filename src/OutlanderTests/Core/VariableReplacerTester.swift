//
//  VariableReplacerTester.swift
//  Outlander
//
//  Created by Joseph McBride on 3/5/19.
//  Copyright © 2019 Joe McBride. All rights reserved.
//

import Foundation
import Quick
import Nimble

class VariableReplacerTester2 : QuickSpec {
    
    override func spec() {

        var context:GameContext?
        var replacer:VariableReplacer2?
        
        describe("variable replacer") {
            
            beforeEach() {
                context = GameContext.newInstance()
                replacer = VariableReplacer2.newInstance()
            }
            
            it("replaces long variables first") {
                let variables:[String:String] = [
                    "brawling_moves": "one|two|three",
                    "brawl":"NO"
                ]

                let result = replacer!.simplify("%brawling_moves", context!.globalVars, [:], [:], variables, [:])
                
                expect(result).to(equal("one|two|three"))
            }
        }
    }
}
