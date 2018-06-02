//
//  LogCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 6/1/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation

extension String {
    func appendLineToURL(fileURL: NSURL) throws {
        try self.stringByAppendingString("\n").appendToURL(fileURL)
    }

    func appendToURL(fileURL: NSURL) throws {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        try data.appendToURL(fileURL)
    }
}

extension NSData {
    func appendToURL(fileURL: NSURL) throws {
        if let fileHandle = try? NSFileHandle(forWritingToURL: fileURL) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.writeData(self)
        }
        else {
            try writeToURL(fileURL, options: .DataWritingAtomic)
        }
    }
}


@objc
class LogCommandHandler : NSObject, CommandHandler {

    private var relay:CommandRelay

    class func newInstance(relay:CommandRelay) -> LogCommandHandler {
        return LogCommandHandler(relay)
    }

    init(_ relay:CommandRelay) {
        self.relay = relay
    }

    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#log ")
    }

    func handle(command: String, withContext: GameContext) {
        let echo = command
            .substringFromIndex(command.startIndex.advancedBy(4))
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        var groups = echo["^(>([\\w\\.\\$%-]+)\\s)?(.*)"].groups()

        var fileName = groups[2]
        var text = groups[3]

        fileName = (fileName == regexNoGroup || fileName == "") ? "\(withContext.settings.character)-\(withContext.settings.game).txt" : fileName
        text = text == regexNoGroup ? "" : text

        do {
            let filePath = "\(withContext.pathProvider.logsFolder())"
            let file = NSURL(fileURLWithPath: filePath).URLByAppendingPathComponent(fileName)!
            try text.appendLineToURL(file)
        }
        catch {
            let tag = TextTag()
            tag.text = "Error writing to file\n"
            self.relay.sendEcho(tag)
        }
    }
}
