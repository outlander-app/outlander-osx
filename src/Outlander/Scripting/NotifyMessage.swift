//
//  NotifyMessage.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

@objc
protocol INotifyMessage {
    func notify(_ message:TextTag)
    func sendCommand(_ command:CommandContext)
    func sendEcho(_ echo:String)
}

@objc
class NotifyMessage : NSObject, INotifyMessage {

    class func newInstance() -> NotifyMessage {
        return NotifyMessage()
    }

    var messageBlock: ((_ message:TextTag) -> Void)?
    var commandBlock: ((_ command:CommandContext) -> Void)?
    var echoBlock: ((_ echo:String) -> Void)?

    func notify(_ message:TextTag) {
        self.messageBlock?(message)
    }

    func sendCommand(_ command:CommandContext) {
        self.commandBlock?(command)
    }

    func sendEcho(_ echo:String) {
        self.echoBlock?(echo)
    }
}
