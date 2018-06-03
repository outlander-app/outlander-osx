//
//  GlobalVariablesTester.swift
//  Outlander
//
//  Created by Joseph McBride on 6/1/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation
import Nimble
import Quick

class GlobalVariablesTester : QuickSpec {

    override func spec() {

        var now = NSDate()
        var settings = AppSettings()
        var variables = GlobalVariables("test.variables", Clock(), settings)
        let formatter = NSDateFormatter()

        func components() -> NSDateComponents {
            return NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: now)
        }

        var formattedDate:String {
            formatter.dateFormat = settings.variableDateFormat
            return formatter.stringFromDate(now)
        }

        var formattedTime:String {
            formatter.dateFormat = settings.variableTimeFormat
            return formatter.stringFromDate(now)
        }
        
        var formattedDatetime:String {
            formatter.dateFormat = settings.variableDatetimeFormat
            return formatter.stringFromDate(now)
        }

        describe("global variables") {

            beforeEach {
                now = NSDate()
                variables = GlobalVariables("test.variables", Clock({ now }), settings)
            }

            it("loads date") {
                let date = variables["date"]
                expect(date).to(equal(formattedDate))
            }

            it("loads time") {
                let time = variables["time"]
                expect(time).to(equal(formattedTime))
            }

            it("loads datetime") {
                let datetime = variables["datetime"]
                expect(datetime).to(equal(formattedDatetime))
            }

            it("sorts keys by length") {
                let keys = variables.keys
                expect(keys).to(equal(["datetime", "date", "time"]))
            }

            it("sorts keys alpha") {
                let keys = variables.sortedKeys({ $0 < $1 })
                expect(keys).to(equal(["date", "datetime", "time"]))
            }
        }
    }
}
