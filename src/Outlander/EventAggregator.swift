//
//  EventAggregator.swift
//  Outlander
//
//  Created by Joseph McBride on 4/25/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
public protocol ISubscriber {
    func handle(_ token:String, data:Dictionary<String, AnyObject>)
}

@objc
open class EventAggregator : NSObject {
    
    fileprivate var handlers:[EventHandler]
    
    override init() {
        handlers = []
    }
    
    open func subscribe(_ subscriber:ISubscriber, token:String) -> String {
        
        let id = UUID().uuidString
        
        let handler = EventHandler(
            id: id,
            subscriber: subscriber,
            token: token
        )
        
        self.handlers.append(handler)
       
        return id
    }
    
    open func unSubscribe(_ id:String) {
        let idx = self.handlers.find { $0.id == id }
        if let found = idx {
            self.handlers.remove(at: found)
        }
    }
    
    open func unSubscribeListener(_ subscriber:ISubscriber) {
        let res = self.handlers.filter { $0.subscriber === subscriber }
        
        for sub in res {
            let idx = self.handlers.find { $0.id == sub.id }
            if let found = idx {
                self.handlers.remove(at: found)
            }
        }
    }
    
    open func unSubscribeAll() {
        self.handlers = []
    }
    
    open func publish(_ token:String, data:Dictionary<String, AnyObject>) {
        let events = self.handlers.filter { $0.token == token }
        
        for ev in events {
            if let sub = ev.subscriber {
                sub.handle(token, data: data)
            }
        }
    }

    open func sendCommand(_ context:CommandContext) {
        publish("OL:command", data: ["command":context])
    }

    open func sendEcho(_ tag:TextTag) {
        publish("OL:echo", data: ["tag":tag])
    }

    open func echoText(_ text:String, mono: Bool = false, preset: String = "") {
        let tag = TextTag()
        tag.text = "\(text)\n"
        tag.mono = mono
        tag.preset = preset
        publish("OL:echo", data: ["tag":tag])
    }
}

public struct EventHandler {
    var id:String
    // TODO: this should be weak, though swift sometimes crashes with it
    var subscriber:ISubscriber?
    var token:String
}
