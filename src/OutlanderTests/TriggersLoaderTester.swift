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
        
        let fileSystem = StubFileSystem()
        let context = GameContext()
        let loader = TriggersLoader(context: context, fileSystem: fileSystem)
        
        describe("triggers") {
            
            beforeEach {
                context.triggers.removeAll()
            }
            
            it("loads trigger") {
                fileSystem.fileContents = "#trigger {^hi} {say hello}"
                
                loader.load()
                
                expect(context.triggers.count()).to(equal(1))
                let trigger = context.triggers.object(at: 0) as! Trigger
                expect(trigger.trigger).to(equal("^hi"))
                expect(trigger.action).to(equal("say hello"))
                expect(trigger.actionClass).to(equal(""))
            }
            
            it("loads trigger with class") {
                fileSystem.fileContents = "#trigger {^hi} {say hello} {people}"
                
                loader.load()
                
                expect(context.triggers.count()).to(equal(1))
                let trigger = context.triggers.object(at: 0) as! Trigger
                expect(trigger.trigger).to(equal("^hi"))
                expect(trigger.action).to(equal("say hello"))
                expect(trigger.actionClass).to(equal("people"))
            }
            
            it("loads multiple triggers") {
                fileSystem.fileContents = "#trigger {^hi} {say hello}\n#trigger {^something} {another}"
                
                loader.load()
                
                expect(context.triggers.count()).to(equal(2))
                
                var trigger = context.triggers.object(at: 0) as! Trigger
                expect(trigger.trigger).to(equal("^hi"))
                expect(trigger.action).to(equal("say hello"))
                
                trigger = context.triggers.object(at: 1) as! Trigger
                expect(trigger.trigger).to(equal("^something"))
                expect(trigger.action).to(equal("another"))
            }
            
            it("saves trigger") {
                let trigger = Trigger("^hi", "say hello", "people")
                context.triggers.add(trigger)
                
                loader.save()
                
                expect(fileSystem.fileContents).to(equal("#trigger {^hi} {say hello} {people}\n"))
            }
            
            it("saves trigger without class") {
                let trigger = Trigger("^hi", "say hello", "")
                context.triggers.add(trigger)
                
                loader.save()
                
                expect(fileSystem.fileContents).to(equal("#trigger {^hi} {say hello}\n"))
            }
            
            it("saves multiple triggers") {
                var trigger = Trigger("^hi", "say hello", "people")
                context.triggers.add(trigger)
                
                trigger = Trigger("^oh", "say I heard ...", "")
                context.triggers.add(trigger)
                
                loader.save()
                
                expect(fileSystem.fileContents).to(equal("#trigger {^hi} {say hello} {people}\n#trigger {^oh} {say I heard ...}\n"))
            }
        }
    }
}
