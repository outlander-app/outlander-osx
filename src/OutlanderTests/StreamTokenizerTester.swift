//
//  StreamTokenizerTester.swift
//  Outlander
//
//  Created by Joseph McBride on 6/2/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Cocoa
import Quick
import Nimble

class StreamTokenizerTester: QuickSpec {
    
    override func spec() {
        describe("tokenizer", {
            
            it("tokenizes text") {
                guard let result = StreamTokenizer().parse("Please wait for connection to game server.\r\n") else {
                    fail("expected result")
                    return
                }

                guard case let .text(val) = result.0 else {
                    fail("expected text result")
                    return
                }

                expect(val).to(equal("Please wait for connection to game server.\n"))
                expect(result.1.count).to(equal(0))
            }

            it("tokenizes text") {
                guard let result = StreamTokenizer().parse("  a diamond-hide raekhlo with a T'Kashi mirror blade and a slender Imperial dagger hanging from it\r\n") else {
                    fail("expected result")
                    return
                }

                guard case let .text(val) = result.0 else {
                    fail("expected text result")
                    return
                }

                expect(val).to(equal("  a diamond-hide raekhlo with a T'Kashi mirror blade and a slender Imperial dagger hanging from it\n"))
                expect(result.1.count).to(equal(0))
            }

            it("tokenizes tag") {
                guard let result = StreamTokenizer().parse("<mode id=\"GAME\"/>\r\n") else {
                    fail("expected result")
                    return
                }

                guard case let .tag(name, attrs, _) = result.0 else {
                    fail("expected tag result")
                    return
                }

                expect(name).to(equal("mode"))
                expect(attrs.count).to(equal(1))
                expect(attrs[0].key).to(equal("id"))
                expect(attrs[0].value).to(equal("GAME"))
                expect(result.1.count).to(equal(1))
            }

            it("tokenizes tag without attributes") {
                guard let result = StreamTokenizer().parse("<popStream/>\r\n") else {
                    fail("expected result")
                    return
                }

                guard case let .tag(name, attrs, _) = result.0 else {
                    fail("expected tag result")
                    return
                }

                expect(name).to(equal("popStream"))
                expect(attrs.count).to(equal(0))
                expect(result.1.count).to(equal(1))
            }

            it("tokenizes tag with multiple attributes") {
                guard let result = StreamTokenizer().parse("<app char=\"Saracus\" game=\"DR\" title=\"[DR: Saracus] StormFront\"/>\r\n") else {
                    fail("expected result")
                    return
                }

                guard case let .tag(name, attrs, _) = result.0 else {
                    fail("expected tag result")
                    return
                }

                expect(name).to(equal("app"))
                expect(attrs.count).to(equal(3))

                expect(attrs[0].key).to(equal("char"))
                expect(attrs[0].value).to(equal("Saracus"))

                expect(attrs[1].key).to(equal("game"))
                expect(attrs[1].value).to(equal("DR"))

                expect(attrs[2].key).to(equal("title"))
                expect(attrs[2].value).to(equal("[DR: Saracus] StormFront"))
                
                expect(result.1.count).to(equal(1))
            }

            it("tokenizes tag with mixed attribute types") {
                guard let result = StreamTokenizer().parse("<container id='stow' title=\"My Backpack\"/>\r\n") else {
                    fail("expected result")
                    return
                }

                guard case let .tag(name, attrs, _) = result.0 else {
                    fail("expected tag result")
                    return
                }

                expect(name).to(equal("container"))
                expect(attrs.count).to(equal(2))

                expect(attrs[0].key).to(equal("id"))
                expect(attrs[0].value).to(equal("stow"))

                expect(attrs[1].key).to(equal("title"))
                expect(attrs[1].value).to(equal("My Backpack"))

                expect(result.1.count).to(equal(1))
            }

            it("tokenizes tag with room name in quotes") {
                guard let result = StreamTokenizer().parse("<streamWindow id='main' title='Story' subtitle=\" - [\"Hodierna's Grace\"]\" location='center' target='drop'/>\r\n") else {
                    fail("expected result")
                    return
                }

                guard case let .tag(name, attrs, _) = result.0 else {
                    fail("expected tag result")
                    return
                }

                expect(name).to(equal("streamWindow"))
                expect(attrs.count).to(equal(5))

                expect(attrs[0].key).to(equal("id"))
                expect(attrs[0].value).to(equal("main"))

                expect(attrs[1].key).to(equal("title"))
                expect(attrs[1].value).to(equal("Story"))

                expect(attrs[2].key).to(equal("subtitle"))
                expect(attrs[2].value).to(equal(" - [Hodierna's Grace]"))

                expect(attrs[3].key).to(equal("location"))
                expect(attrs[3].value).to(equal("center"))

                expect(attrs[4].key).to(equal("target"))
                expect(attrs[4].value).to(equal("drop"))

                expect(result.1.count).to(equal(1))
            }

            it("tokenizes multiple tokens") {
                let tokens = StreamTokenizer().tokenize("<streamWindow id='inv' title='My Inventory' target='wear' ifClosed='' resident='true'/><clearStream id='inv' ifClosed=''/><pushStream id='inv'/>Your worn items are:\r\n")

                expect(tokens.count).to(equal(4))

                guard case let .text(text) = tokens[3] else {
                    fail("expect text token")
                    return
                }

                expect(text).to(equal("Your worn items are:\n"))
            }

            it("tokenizes tag with child text") {
                let tokens = StreamTokenizer().tokenize("<inv id='stow'>In the backpack:</inv>\r\n")

                expect(tokens.count).to(equal(2))

                guard case let .tag(name, attrs, children) = tokens[0] else {
                    fail("expected tag token")
                    return
                }

                expect(name).to(equal("inv"))

                expect(attrs.count).to(equal(1))
                expect(attrs[0].key).to(equal("id"))
                expect(attrs[0].value).to(equal("stow"))

                expect(children.count).to(equal(1))

                guard case let .text(text) = children[0] else {
                    fail("expected text token")
                    return
                }

                expect(text).to(equal("In the backpack:"))
            }

            it("tokenizes compDef tag") {
                let tokens = StreamTokenizer().tokenize("<compDef id='exp Shield Usage'></compDef>\r\n")

                expect(tokens.count).to(equal(2))

                guard case let .tag(name, attrs, children) = tokens[0] else {
                    fail("expected tag token")
                    return
                }

                expect(name).to(equal("compDef"))

                expect(attrs.count).to(equal(1))
                expect(attrs[0].key).to(equal("id"))
                expect(attrs[0].value).to(equal("exp Shield Usage"))

                expect(children.count).to(equal(0))
            }

            it("tokenizes tag with child tags") {
                let tokens = StreamTokenizer().tokenize("<dialogData id='minivitals'><skin id='healthSkin' name='healthBar' controls='health' left='0%' top='0%' width='20%' height='100%'/><progressBar id='health' value='100' text='health 100%' left='0%' customText='t' top='0%' width='20%' height='100%'/></dialogData>")

                expect(tokens.count).to(equal(2))

                guard case let .tag(name, attrs, children) = tokens[0] else {
                    fail("expected tag token")
                    return
                }

                expect(name).to(equal("dialogData"))

                expect(attrs.count).to(equal(1))
                expect(attrs[0].key).to(equal("id"))
                expect(attrs[0].value).to(equal("minivitals"))

                expect(children.count).to(equal(2))

                guard case let .tag(name1, attrs1, children1) = children[0] else {
                    fail("expected tag token")
                    return
                }

                expect(name1).to(equal("skin"))
                expect(attrs1.count).to(equal(7))
                expect(attrs1[1].key).to(equal("name"))
                expect(attrs1[1].value).to(equal("healthBar"))
                expect(children1.count).to(equal(0))

                guard case let .tag(name2, attrs2, children2) = children[1] else {
                    fail("expected tag token")
                    return
                }

                expect(name2).to(equal("progressBar"))
                expect(attrs2.count).to(equal(8))
                expect(attrs2[0].key).to(equal("id"))
                expect(attrs2[0].value).to(equal("health"))
                expect(attrs2[2].key).to(equal("text"))
                expect(attrs2[2].value).to(equal("health 100%"))
                expect(children2.count).to(equal(0))
            }

            it("tokenizes tag with child tags") {
                let tokens = StreamTokenizer().tokenize("<openDialog type='dynamic' id='minivitals' title='Stats' location='statBar'><dialogData id='minivitals'></dialogData></openDialog>")

                expect(tokens.count).to(equal(2))

                guard case let .tag(name, attrs, children) = tokens[0] else {
                    fail("expected tag token")
                    return
                }

                expect(name).to(equal("openDialog"))

                expect(attrs.count).to(equal(4))
                expect(attrs[1].key).to(equal("id"))
                expect(attrs[1].value).to(equal("minivitals"))

                expect(children.count).to(equal(1))

                guard case let .tag(name1, attrs1, children1) = children[0] else {
                    fail("expected tag token")
                    return
                }

                expect(name1).to(equal("dialogData"))
                expect(attrs1.count).to(equal(1))
                expect(attrs1[0].key).to(equal("id"))
                expect(attrs1[0].value).to(equal("minivitals"))
                expect(children1.count).to(equal(0))
            }

        })
    }
}
