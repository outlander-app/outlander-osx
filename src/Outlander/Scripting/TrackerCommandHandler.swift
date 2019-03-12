//
//  TrackerCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 3/12/19.
//  Copyright © 2019 Joe McBride. All rights reserved.
//

import Foundation

@objc
class TrackerCommandHandler : NSObject, CommandHandler {

    class func newInstance() -> TrackerCommandHandler {
        return TrackerCommandHandler()
    }

    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("/tracker")
    }

    func handle(command: String, withContext: GameContext) {

        let text = command
            .substringFromIndex(command.startIndex.advancedBy(8))
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        if text.characters.count == 0 {
            withContext.events.echoText("\nExperience Tracker", mono: true, preset: "default")
            withContext.events.echoText("Available commands:", mono: true, preset: "default")
            withContext.events.echoText("  orderby: order skills by skillset, name, name desc, ranks, ranks desc.", mono: true, preset: "default")
            withContext.events.echoText("  report:  display a report of skills with field experience or earned ranks.", mono: true, preset: "default")
            withContext.events.echoText("  reset:   resets the tracking data.", mono: true, preset: "default")
            withContext.events.echoText("  update:  refreshes the experience window.", mono: true, preset: "default")
            withContext.events.echoText("", mono: true, preset: "default")

        } else {

            var commands = text.componentsSeparatedByString(" ")
            let cmd = commands.removeFirst()
            let value = commands.joinWithSeparator(" ")
            withContext.events.publish("OL:tracker", data: ["command":cmd, "value": value])
        }
    }
}
