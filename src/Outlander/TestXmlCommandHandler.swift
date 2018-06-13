//
//  TestXmlCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 6/8/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation

@objc
class TestXmlCommandHandler : NSObject, CommandHandler {

    class func newInstance() -> TestXmlCommandHandler {
        return TestXmlCommandHandler()
    }

    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#testxml ")
    }

    func handle(command: String, withContext: GameContext) {
        let xml = command
            .substringFromIndex(command.startIndex.advancedBy(9))

        withContext.events.publish("ol:testxml", data: ["xml":xml])
    }
}
