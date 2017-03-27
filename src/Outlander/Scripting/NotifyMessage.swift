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
    func notify(_ message:TextTag)
    func sendCommand(_ command:CommandContext)
    func sendEcho(_ echo:String)
}

@objc
open class NotifyMessage : NSObject, INotifyMessage {

    class func newInstance() -> NotifyMessage {
        return NotifyMessage()
    }

    var messageBlock: ((_ message:TextTag) -> Void)?
    var commandBlock: ((_ command:CommandContext) -> Void)?
    var echoBlock: ((_ echo:String) -> Void)?

    public override init() {
    }

    open func notify(_ message:TextTag) {
        self.messageBlock?(message)
    }

    open func sendCommand(_ command:CommandContext) {
        self.commandBlock?(command)
    }

    open func sendEcho(_ echo:String) {
        self.echoBlock?(echo)
    }
}
