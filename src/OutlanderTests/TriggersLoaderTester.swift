//
//  TriggersLoaderTester.swift
//  Outlander
//
//  Created by Joseph McBride on 6/5/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation
import Nimble
import Quick

class TriggersLoaderTester : QuickSpec {
    
    override func spec() {
        
        var fileSystem = StubFileSystem()
        var context = GameContext()
        var loader = TriggersLoader(context: context, fileSystem: fileSystem)
        
        describe("triggers") {
            
            beforeEach {
                context.triggers.removeAll()
            }
            
            it("loads triggers") {
                fileSystem.fileContents = "#trigger {^hi} {say hello}"
                
                loader.load()
                
                expect(context.triggers.count()).to(equal(1))
                let trigger = context.triggers.objectAtIndex(0) as! Trigger
                expect(trigger.trigger).to(equal("^hi"))
                expect(trigger.action).to(equal("say hello"))
            }
        }
    }
}