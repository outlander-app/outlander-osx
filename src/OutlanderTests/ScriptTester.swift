//
//  ParserTests.swift
//  Outlander
//
//  Created by Joseph McBride on 4/4/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation
import Nimble
import Quick

enum SomeValue : Hashable {

    typealias RawValue = Int

    case first
    case second(String)
    case third(String,String)

    var rawValue: RawValue {
        switch self {
            case .first: return 0
            case .second: return 1
            case .third: return 2
        }
    }

    var hashValue: Int {
        return self.rawValue.hashValue
    }

    static func == (lhs:SomeValue, rhs:SomeValue) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

class SomeEnums {
    var lookup:[SomeValue:(SomeValue) -> Bool] = [:]
}

class ScriptTester : QuickSpec {

    override func spec() {

        describe("the script") {

            beforeEach() {
            }

            it("does something") {
                let enums = SomeEnums()
                enums.lookup[.first] = {e in
                    return true
                }

                let val = SomeValue.first
                expect(enums.lookup[val]!(val)).to(beTrue())
            }

            it("does something") {

                let enums = SomeEnums()
                enums.lookup[.second("")] = {e in
                    return true
                }

                let val = SomeValue.second("testing")
                expect(enums.lookup[val]!(val)).to(beTrue())
            }

            it("does something") {

                func someFunc(in:SomeValue) -> Bool {
                    return true
                }
                
                let enums = SomeEnums()
                enums.lookup[.third("", "")] = someFunc

                let val = SomeValue.third("testing", "one")
                expect(enums.lookup[val]!(val)).to(beTrue())
            }
        }
    }
}
