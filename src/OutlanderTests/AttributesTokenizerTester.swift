//
//  AttributesTokenizerTester.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation
import Quick
import Nimble

class AttributesTokenizerTester: QuickSpec {

    override func spec() {
        describe("tokenizer", {
            
            it("tokenizes single quote attributes") {
                let data = "one='two' three='four'"
                let tokenizer = AttributesTokenizer()
                let result = tokenizer.tokenize(data)
                
                expect(result.count).to(equal(2))
                expect(Array(result.keys)).to(equal(["one", "three"]))
                expect(Array(result.values)).to(equal(["two", "four"]))
            }
            
            it("tokenizes double quote attributes") {
                let data = "one=\"two\" three=\"four\""
                let tokenizer = AttributesTokenizer()
                let result = tokenizer.tokenize(data)
               
                expect(result.count).to(equal(2))
                expect(Array(result.keys)).to(equal(["one", "three"]))
                expect(Array(result.values)).to(equal(["two", "four"]))
            }
            
            it("tokenizes mixed quote attributes") {
                let data = "title='Room' subtitle=\" - [Barana's Shipyard, Receiving Yard]\""
                let tokenizer = AttributesTokenizer()
                let result = tokenizer.tokenize(data)
               
                expect(result.count).to(equal(2))
                expect(Array(result.keys)).to(equal(["title", "subtitle"]))
                expect(Array(result.values)).to(equal(["Room", " - [Barana's Shipyard, Receiving Yard]"]))
            }
            
            it("tokenizer handles extra spaces") {
                let data = " id=\"roomName\" "
                let tokenizer = AttributesTokenizer()
                let result = tokenizer.tokenize(data)
               
                expect(result.count).to(equal(1))
                expect(Array(result.keys)).to(equal(["id"]))
                expect(Array(result.values)).to(equal(["roomName"]))
            }
        })
    }
}
