//
//  SendQueue.swift
//  Outlander
//
//  Created by Joseph McBride on 6/2/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation

@objc
public class SendQueue : NSObject, ISubscriber {

    class func newInstance(context:GameContext) -> SendQueue {
        return SendQueue(context)
    }

    private let context:GameContext
    private var queue:[String]

    init(_ context:GameContext) {
        self.context = context
        self.queue = []
        super.init()

        context.events.subscribe(self, token: "variable:changed")
    }

    public func enqueue(command:String) {
        self.queue.append(command)
        self.check()
    }

    public func handle(token: String, data: Dictionary<String, AnyObject>) {
        guard data.first?.0 == "roundtime" else { return }
        self.check()
    }

    private func check() {
        let roundtime = context.globalVars["roundtime"]?.toDouble()
        if roundtime <= 0 {
            self.dump()
        }
    }

    private func dequeue() -> String? {
        if(self.queue.count > 0) {
            return self.queue.removeAtIndex(0)
        }
        return nil
    }

    private func dump() {
        while let commands = self.dequeue() {
            let commandsList = commands.splitToCommands()
            for cmd in commandsList {
                let ctx = CommandContext()
                ctx.command = cmd.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                ctx.tag = TextTag.init("\(ctx.command)\n", mono: true)
                ctx.tag.preset = "sendinput"
                ctx.isSystemCommand = true
                self.context.events.sendCommand(ctx)
            }
        }
    }
}
