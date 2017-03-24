//
//  NotifyMessage.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

@objc
public protocol INotifyMessage {
    func notify(message:TextTag)
    func sendCommand(command:CommandContext)
    func sendEcho(echo:String)
}

@objc
public class NotifyMessage : NSObject, INotifyMessage {

    class func newInstance() -> NotifyMessage {
        return NotifyMessage()
    }

    var messageBlock: ((message:TextTag) -> Void)?
    var commandBlock: ((command:CommandContext) -> Void)?
    var echoBlock: ((echo:String) -> Void)?

    public override init() {
    }

    public func notify(message:TextTag) {
        self.messageBlock?(message: message)
    }

    public func sendCommand(command:CommandContext) {
        self.commandBlock?(command: command)
    }

    public func sendEcho(echo:String) {
        self.echoBlock?(echo: echo)
    }
}
