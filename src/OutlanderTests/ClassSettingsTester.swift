//
//  ClassSettingsTester.swift
//  Outlander
//
//  Created by Joseph McBride on 3/14/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation
import Nimble
import Quick

class ClassSettingsTester : QuickSpec {

    override func spec() {

        var settings:ClassSettings = ClassSettings()

        describe("class settings") {

            beforeEach() {
                settings = ClassSettings()
            }

            it("returns all settings") {

                settings.set("one", value: false)
                settings.set("two", value: true)

                let all = settings.all()

                expect(all.count).to(equal(2))

                expect(all[0].key).to(equal("one"))
                expect(all[0].value).to(equal(false))

                expect(all[1].key).to(equal("two"))
                expect(all[1].value).to(equal(true))
            }

            it("returns false settings") {

                settings.set("one", value: false)
                settings.set("two", value: true)

                expect(settings.disabled()).to(equal(["one"]))
            }

            it("sets all settings on") {

                settings.set("one", value: false)
                settings.set("two", value: true)

                settings.allOn()

                expect(settings.disabled()).to(equal([]))
            }

            it("sets all settings off") {

                settings.set("one", value: false)
                settings.set("two", value: true)

                settings.allOff()

                expect(settings.disabled()).to(equal(["one", "two"]))
            }

            it("sets target on") {

                settings.set("one", value: false)

                settings.parse("+one")

                expect(settings.disabled()).to(equal([]))
            }

            it("sets target off") {

                settings.set("one", value: true)

                settings.parse("-one")

                expect(settings.disabled()).to(equal(["one"]))
            }

            it("parses on setting") {

                let s = settings.parseSetting("+one")

                expect(s.key).to(equal("one"))
                expect(s.value).to(equal(true))
            }

            it("parses off setting") {

                let s = settings.parseSetting("-one")

                expect(s.key).to(equal("one"))
                expect(s.value).to(equal(false))
            }

            it("sets multiple targets") {

                settings.set("one", value: true)
                settings.set("five", value: false)

                settings.parse("-one +three -four +five")

                expect(settings.disabled()).to(equal(["four", "one"]))
            }

            it("sets target off") {

                settings.set("one", value: true)

                settings.parse("one off")

                expect(settings.disabled()).to(equal(["one"]))
            }

            it("sets target on") {

                settings.set("one", value: false)

                settings.parse("one on")

                expect(settings.disabled()).to(equal([]))
            }

            it("sets all on") {

                settings.set("one", value: false)
                settings.set("two", value: true)
                settings.set("three", value: false)

                settings.parse("all on")

                expect(settings.disabled()).to(equal([]))
            }

            it("sets all off") {

                settings.set("one", value: false)
                settings.set("two", value: true)
                settings.set("three", value: true)

                settings.parse("all off")

                expect(settings.disabled()).to(equal(["one", "three", "two"]))
            }
        }
    }
}
