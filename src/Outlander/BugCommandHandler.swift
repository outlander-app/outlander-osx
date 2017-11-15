//
//  BugCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 11/14/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

@objc
class BugCommandHandler : NSObject, CommandHandler {

    class func newInstance() -> BugCommandHandler {
        return BugCommandHandler()
    }

    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#bug")
    }

    func handle(command: String, withContext: GameContext) {
        let url = NSURL(string: "https://github.com/joemcbride/outlander-osx/issues/new")
        NSWorkspace.sharedWorkspace().openURL(url!)
    }
}
