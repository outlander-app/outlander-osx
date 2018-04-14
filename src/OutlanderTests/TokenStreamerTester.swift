//
//  TokenStreamerTester.swift
//  Outlander
//
//  Created by Joseph McBride on 6/9/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation
import Quick
import Nimble

class TokenStreamerTester: QuickSpec {

    override func spec() {
        describe("token streamer", {

            it("prompt") {
                let tokens = StreamTokenizer().tokenize("<prompt time=\"1484960727\">&gt;</prompt>")
                let streamer = TokenStreamer()
                streamer.stream(tokens)

                expect(streamer.textTags.count).to(equal(2))
                let tag = streamer.textTags.front!
                expect(tag.text).to(equal("&gt;"))
            }
        })
    }
}
